import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';
import 'package:sydney_webui/widgets/chat_drawer.dart';
import 'package:sydney_webui/widgets/message_list.dart';
import 'package:sydney_webui/widgets/prompt_input.dart';
import 'package:sydney_webui/widgets/settings_dialog.dart';

class ChatPage extends StatelessWidget {
  final controller = Get.put(Controller());

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sydney Chat'),
          actions: [
            Obx(() => IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  onPressed: controller.isGenerating.value
                      ? null
                      : () {
                          controller.newConversation();
                          Get.back();
                        },
                )),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  Get.dialog(const SettingsDialog(), barrierDismissible: false),
            ),
            const SizedBox(width: 8)
          ],
        ),
        drawer: const ChatDrawer(),
        body: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                MessageList(),
                SizedBox(height: 16),
                PromptInput(),
              ],
            )));
  }
}
