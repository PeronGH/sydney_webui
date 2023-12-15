import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    final fixedChildren = <Widget>[
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
      const Divider(),
    ];

    return Drawer(
      child: GetBuilder(
          id: Controller.idConversationList,
          builder: (Controller controller) {
            final conversationIds =
                controller.conversationHistory.keys.toList(growable: false);

            return ListView.builder(
                itemCount: fixedChildren.length + conversationIds.length,
                itemBuilder: (context, index) {
                  // Render fixed children first
                  if (index < fixedChildren.length) {
                    return fixedChildren[index];
                  }

                  index -= fixedChildren.length;

                  // Render conversation list
                  final conversationId = conversationIds[index];

                  return ListTile(
                      leading: const Icon(Icons.chat),
                      selected: conversationId ==
                          controller.currentConversationId.value,
                      title: Text(conversationId),
                      onTap: () {
                        controller.loadConversation(conversationId);
                        Get.back();
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            controller.deleteConversation(conversationId),
                      ));
                });
          }),
    );
  }
}
