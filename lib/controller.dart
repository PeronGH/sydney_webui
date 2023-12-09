import 'package:flutter/material.dart';
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

  // Reactive variables
  final isGenerating = false.obs;
  final prompt = ''.obs;
  final messages = <Message>[
    Message(
        role: Message.roleSystem,
        type: Message.typeAdditionalInstructions,
        content: Message.defaultSystemMessage),
  ].obs;

  final generatingType = ''.obs;
  final generatingContent = ''.obs;

  // Getters
  bool get canSubmit => prompt.value.isNotEmpty && !isGenerating.value;

  // Methods
  void _clearPrompt() {
    prompt.value = '';
    promptController.clear();
  }

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

    _clearPrompt();

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

  void uploadImage() async {}

  void deleteMessageAt(int index) {
    final removed = messages.removeAt(index);

    if (removed.role == Message.roleSystem) return;

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
  }

  // Helper methods
  void _onGenerateProgress(String type, String content) {
    if (!isGenerating.value) return;

    if (generatingType.value != type) {
      _saveGeneratedMessage();
    }

    generatingType.value = type;
    generatingContent.value += content;
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
}
