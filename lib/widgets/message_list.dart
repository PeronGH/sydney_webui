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
                  // Last one is the message being generated or user input
                  return Obx(() => controller.isGenerating.value
                      ? MessageTile(
                          message: Message(
                              role: Message.roleAssistant,
                              type: controller.generatingType.value,
                              content: controller.generatingContent.value))
                      : MessageTile(
                          message: Message(
                              role: Message.roleUser,
                              type: Message.typeTyping,
                              content: controller.prompt.value)));
                }

                // Render normal message
                final message = controller.messages[index];

                return MessageTile(
                  message: message,
                  deleteButton: Obx(() => IconButton(
                        onPressed: controller.isGenerating.value
                            ? null
                            : () => controller.deleteMessageAt(index),
                        icon: const Icon(Icons.delete_outline),
                      )),
                  editButton: Obx(() => IconButton(
                        onPressed: controller.isGenerating.value
                            ? null
                            : () => controller.editMessageAt(index),
                        icon: const Icon(Icons.edit_outlined),
                      )),
                );
              },
            );
          }),
    );
  }
}
