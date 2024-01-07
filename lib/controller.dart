import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/services/sharegpt_service.dart';
import 'package:sydney_webui/services/sydney_service.dart';
import 'package:sydney_webui/utils/url.dart';

class Controller extends GetxController {
  // Constants
  static const idMessageList = 'messageList';
  static const idConversationList = 'conversationList';

  // Services
  final sydneyService = SydneyService();
  final shareGptService = ShareGptService();

  // Controllers
  final promptController = TextEditingController();
  final scrollController = ScrollController();

  // Reactive variables
  final isGenerating = false.obs;
  final prompt = ''.obs;
  final messages = <Message>[].obs;

  final currentConversationId = ''.obs;
  final conversationHistory = <String, List<Message>>{}.obs;

  final generatingType = ''.obs;
  final generatingContent = ''.obs;

  // Getters
  bool get canSubmit => prompt.value.isNotEmpty && !isGenerating.value;

  // Methods
  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();

    // Update prompt reactive variable when prompt controller changes
    promptController.addListener(() {
      if (promptController.text == prompt.value) return;
      prompt.value = promptController.text;
    });

    // Update message list when messages changes
    ever(messages, (_) => update([idMessageList]));

    // Initialize with default message
    newConversation();

    // Update conversation id when id or list changes
    ever(currentConversationId, (_) => update([idConversationList]));
    ever(conversationHistory, (_) => update([idConversationList]));

    // Load conversation history
    final Map<String, dynamic>? history = box.read('conversationHistory');
    if (history != null) {
      conversationHistory.value = history.map((key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((e) => Message.fromJson(e))
              .toList(growable: false)));
    }

    // Save conversation history when there is any change
    ever(conversationHistory,
        (value) => box.write('conversationHistory', value));

    // Save current conversation once there is any reply
    ever(messages, (value) {
      if (messages.any((msg) => msg.role == Message.roleAssistant)) {
        conversationHistory[currentConversationId.value] = value;
      }
    });
  }

  void submit() async {
    if (!canSubmit) return;

    isGenerating.value = true;

    final userPrompt = prompt.value;
    setPrompt("");
    await _submit(userPrompt);

    // handle message revoke
    for (var retries = 0;
        retries < 3 &&
            messages.isNotEmpty &&
            messages.last.type == Message.typeError &&
            messages.last.content == Message.messageRevoke;
        retries++) {
      await _submit(Message.continueFromRevokeMessage);
    }

    isGenerating.value = false;
  }

  Future<void> _submit(String userPrompt) async {
    // Generate context without prompt
    final context = messages.toContext();

    // Add prompt to message list as user message
    messages.add(Message(
        role: Message.roleUser,
        type: Message.typeMessage,
        content: userPrompt,
        imageUrls: sydneyService.imageUrl.value.isEmpty
            ? null
            : [sydneyService.imageUrl.value]));

    // Scroll to bottom
    SchedulerBinding.instance
        .addPostFrameCallback((_) => scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            ));

    try {
      await for (final event
          in sydneyService.askStream(prompt: userPrompt, context: context)) {
        _onGenerateProgress(event.type, event.content);
      }
    } catch (e) {
      Get.snackbar("Error occurred", "Failed to generate message: $e");
      e.printError();
    }

    _saveGeneratedMessage();
  }

  Message deleteMessageAt(int index) {
    final removed = messages.removeAt(index);

    if (removed.role == Message.roleSystem) return removed;

    // remove all following messages
    while (index < messages.length) {
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
    setPrompt(removed.content);
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
    if (isGenerating.value) return;

    // Clear prompt and image
    setPrompt("");
    sydneyService.imageUrl.value = '';

    // Update conversation id
    currentConversationId.value = DateTime.now().toString();

    // Reset message list
    messages.value = <Message>[
      Message(
          role: Message.roleSystem,
          type: Message.typeAdditionalInstructions,
          content: sydneyService.systemMessage)
    ];
  }

  void setPrompt(String prompt) {
    promptController.text = prompt;
  }

  void updateSystemMessage() {
    if (isGenerating.value) return;
    if (messages.isEmpty) return;
    if (messages.first.role != Message.roleSystem) return;
    if (messages.first.type != Message.typeAdditionalInstructions) return;

    messages.first = Message(
        role: Message.roleSystem,
        type: Message.typeAdditionalInstructions,
        content: sydneyService.systemMessage);
  }

  void loadConversation(String conversationId) {
    if (isGenerating.value) return;

    final conversation = conversationHistory[conversationId];
    if (conversation == null) return;

    currentConversationId.value = conversationId;
    messages.value = conversation.toList();
  }

  void deleteConversation(String conversationId) {
    if (isGenerating.value) return;

    if (conversationId == currentConversationId.value) {
      newConversation();
    }
    conversationHistory.remove(conversationId);
  }

  void shareConversation() async {
    if (isGenerating.value) return;

    Get.snackbar('Uploading', 'Uploading conversation to ShareGPT...');
    try {
      final id = await shareGptService.uploadConversation(messages);
      final url = 'https://shareg.pt/$id';
      await openUrl(url);
    } catch (e) {
      Get.snackbar('Error occurred', 'Failed to share conversation: $e');
    }
  }
}
