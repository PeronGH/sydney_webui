import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';
import 'package:sydney_webui/widgets/message_list.dart';
import 'package:sydney_webui/widgets/prompt_input.dart';
import 'package:sydney_webui/widgets/settings_dialog.dart';

class ChatPage extends StatelessWidget {
  final controller = Get.put(Controller());

  ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sydney Chat'),
          actions: [
            IconButton(
                onPressed: () => showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: const SettingsDialog().build),
                icon: const Icon(Icons.settings))
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              Obx(() => ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('New Conversation'),
                    onTap: controller.isGenerating.value
                        ? null
                        : () {
                            controller.newConversation();
                            Get.back();
                          },
                  )),
            ],
          ),
        ),
        body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                MessageList(),
                SizedBox(height: 16.0),
                PromptInput(),
              ],
            )));
  }
}
