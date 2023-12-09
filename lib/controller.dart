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
  var isGenerating = false.obs;
  var prompt = ''.obs;
  var messages = <Message>[
    Message(
        role: Message.roleSystem,
        type: Message.typeAdditionalInstructions,
        content: Message.defaultSystemMessage),
  ].obs;

  var generatingType = ''.obs;
  var generatingContent = ''.obs;

  // Getters
  bool get canSubmit => prompt.value.isNotEmpty && !isGenerating.value;

  // Methods
  @override
  void onInit() {
    super.onInit();

    // Sync prompt input with prompt reactive variable
    promptController.addListener(() {
      if (promptController.text == prompt.value) return;
      prompt.value = promptController.text;
    });
    ever(prompt, (prompt) => promptController.text = prompt);

    // Update message list when messages changes
    ever(messages, (_) => update([idMessageList]));
  }

  void submit() async {
    if (!canSubmit) return;

    isGenerating.value = true;

    // Add prompt to message list as user message
    final userPrompt = prompt.value;
    messages.add(Message(
        role: Message.roleUser,
        type: Message.typeMessage,
        content: userPrompt));

    prompt.value = '';

    // TODO: Generate response from Sydney
    _onGenerateProgress(Message.typeLoading, "Loading...");
    for (var i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _onGenerateProgress(Message.typeMessage, i.toString());
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
