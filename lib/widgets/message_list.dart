import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sydney_webui/controller.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/widgets/message_tile.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<Controller>(
          id: Controller.idMessageList,
          builder: (controller) {
            return ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.messages.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.messages.length) {
                  // Only render last one (generating message) when generating
                  return Obx(() => controller.isGenerating.value
                      ? MessageTile(
                          message: Message(
                              role: Message.roleAssistant,
                              type: controller.generatingType.value,
                              content: controller.generatingContent.value))
                      : const SizedBox.shrink());
                }

                // Render normal message
                final message = controller.messages[index];
                return MessageTile(
                    message: message,
                    deleteButton: Obx(
                      () => controller.isGenerating.value
                          ? const IconButton(
                              onPressed: null,
                              icon: Icon(Icons.delete_outline),
                            )
                          : IconButton(
                              onPressed: () =>
                                  controller.deleteMessageAt(index),
                              icon: const Icon(Icons.delete_outline),
                            ),
                    ));
              },
            );
          }),
    );
  }
}
