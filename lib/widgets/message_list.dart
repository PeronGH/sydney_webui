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
                          index: index,
                          isBeingGenerated: true,
                          message: Message(
                              role: Message.roleAssistant,
                              type: controller.generatingType.value,
                              content: controller.generatingContent.value))
                      : MessageTile(
                          index: index,
                          isBeingGenerated: true,
                          message: Message(
                              role: Message.roleUser,
                              type: Message.typeTyping,
                              content: controller.prompt.value)));
                }

                // Render normal message
                final message = controller.messages[index];
                return MessageTile(
                  index: index,
                  message: message,
                );
              },
            );
          }),
    );
  }
}
