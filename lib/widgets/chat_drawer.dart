import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    return Drawer(
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
          ListTile(
            leading: const Icon(Icons.copy_all),
            title: const Text('Copy Conversation'),
            onTap: controller.copyConversation,
          ),
          Obx(() => ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: const Text('Import Conversation'),
                onTap: controller.isGenerating.value
                    ? null
                    : controller.importConversation,
              )),
        ],
      ),
    );
  }
}
