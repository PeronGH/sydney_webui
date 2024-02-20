import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    final fixedChildren = <Widget>[
      Obx(() => ListTile(
            leading: const Icon(Icons.add_box_outlined),
            title: const Text('New Conversation'),
            onTap: controller.isGenerating.value
                ? null
                : () {
                    controller.newConversation();
                    Get.back();
                  },
          )),
      Obx(() => ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text("Share Conversation"),
            onTap: controller.isGenerating.value
                ? null
                : controller.shareConversation,
          )),
      const Divider(),
    ];

    return Drawer(
      child: GetBuilder(
          id: Controller.idConversationList,
          builder: (Controller controller) {
            final conversationIds = controller.conversationHistory.keys
                .toList(growable: false)
                .reversed
                .toList(growable: false);

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
                      key: ValueKey(conversationId),
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
