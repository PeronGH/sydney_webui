import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/services/sydney_service.dart';

class Controller extends GetxController {
  // Constants
  static const String idMessageList = 'messageList';

  // Services
  final sydneyService = SydneyService();

  // Controllers
  final promptController = TextEditingController();
  final scrollController = ScrollController();

  // Reactive variables
  final isGenerating = false.obs;
  final prompt = ''.obs;
  final messages = <Message>[].obs;

  final generatingType = ''.obs;
  final generatingContent = ''.obs;

  // Getters
  bool get canSubmit => prompt.value.isNotEmpty && !isGenerating.value;

  // Methods
  @override
  void onInit() {
    super.onInit();

    // Update prompt reactive variable when prompt controller changes
    promptController.addListener(() {
      if (promptController.text == prompt.value) return;
      prompt.value = promptController.text;
    });

    // Update message list when messages changes
    ever(messages, (_) => update([idMessageList]));

    // initialize with default message
    newConversation();
  }

  void submit() async {
    if (!canSubmit) return;

    isGenerating.value = true;

    // Generate context without prompt
    final context = messages.toContext();

    // Add prompt to message list as user message
    final userPrompt = prompt.value;
    messages.add(Message(
        role: Message.roleUser,
        type: Message.typeMessage,
        content: userPrompt));

    // Scroll to bottom
    SchedulerBinding.instance
        .addPostFrameCallback((_) => scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            ));

    promptController.clear();

    try {
      await for (final event
          in sydneyService.askStream(prompt: userPrompt, context: context)) {
        _onGenerateProgress(event.type, event.content);
      }
    } catch (e) {
      Get.snackbar("Error occurred", e.toString());
      e.printError();
    }

    _saveGeneratedMessage();

    isGenerating.value = false;
  }

  Message deleteMessageAt(int index) {
    final removed = messages.removeAt(index);

    if (removed.role == Message.roleSystem) return removed;

    // remove any next assistant messages
    while (index < messages.length &&
        messages[index].role == Message.roleAssistant) {
      messages.removeAt(index);
    }

    if (removed.role == Message.roleAssistant) {
      // remove any previous assistant messages
      while (index > 0 && messages[index - 1].role == Message.roleAssistant) {
        messages.removeAt(--index);
      }

      // remove user message too
      if (index > 0 && messages[index - 1].role == Message.roleUser) {
        messages.removeAt(--index);
      }
    }

    return removed;
  }

  void editMessageAt(int index) {
    final removed = deleteMessageAt(index);
    promptController.text = removed.content;
  }

  // Helper methods
  void _onGenerateProgress(String type, String content) {
    if (generatingType.value != type) {
      _saveGeneratedMessage();
    }

    switch (type) {
      // remove duplicated contents
      case Message.typeSuggestedResponses:
      case Message.typeSearchResult:
        if (generatingContent.value.startsWith(content)) return;
        break;
      // handle image generation
      case Message.typeGenerativeImage:
        final index = messages.length;
        final generativeImage = jsonDecode(content);
        content = 'Generating "${generativeImage['text']}"...';
        () async {
          try {
            final urls =
                await sydneyService.getGenerativeImageUrls(generativeImage);

            if (messages.length <= index) return;
            if (messages[index].type != Message.typeGenerativeImage) return;
            if (messages[index].content != content) return;

            messages[index] = Message(
                role: Message.roleAssistant,
                type: Message.typeGenerativeImage,
                content: generativeImage["text"],
                imageUrls: urls);
          } catch (e) {
            Get.snackbar('Error occurred', 'Failed to generate image: $e');

            if (messages.length <= index) return;
            if (messages[index].type != Message.typeGenerativeImage) return;
            if (messages[index].content != content) return;

            messages[index] = Message(
                role: Message.roleAssistant,
                type: Message.typeError,
                content: 'Failed to generate image: ${e.toString()}');
          }
        }();
        break;
    }

    final isAtBottom = scrollController.position.pixels ==
        scrollController.position.maxScrollExtent;

    generatingType.value = type;
    generatingContent.value += content;

    // Scroll to new bottom if already at bottom
    if (isAtBottom) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => scrollController.jumpTo(
                scrollController.position.maxScrollExtent,
              ));
    }
  }

  void _saveGeneratedMessage() {
    if (generatingType.value.isEmpty) return;

    messages.add(Message(
        role: Message.roleAssistant,
        type: generatingType.value,
        content: generatingContent.value));

    generatingType.value = '';
    generatingContent.value = '';
  }

  void newConversation() {
    // Clear prompt and image
    promptController.clear();
    sydneyService.imageUrl.value = '';

    messages.value = <Message>[
      Message(
          role: Message.roleSystem,
          type: Message.typeAdditionalInstructions,
          content: Message.defaultSystemMessage)
    ];
  }
}
