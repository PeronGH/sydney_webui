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
          builder: (controller) => ListView.builder(
                controller: controller.scrollController,
                itemCount: controller.messages.length + 1,
                itemBuilder: (context, index) {
                  Widget messageTile;

                  if (index == controller.messages.length) {
                    messageTile = Obx(() => controller.isGenerating.value
                        // The message being generated
                        ? MessageTile(
                            index: index,
                            isBeingGenerated: true,
                            message: Message(
                                role: Message.roleAssistant,
                                type: controller.generatingType.value,
                                content: controller.generatingContent.value))
                        // User input
                        : MessageTile(
                            index: index,
                            isBeingGenerated: true,
                            message: Message(
                              role: Message.roleUser,
                              type: Message.typeTyping,
                              content: controller.prompt.value,
                              imageUrls: controller
                                      .sydneyService.imageUrl.isEmpty
                                  ? null
                                  : [controller.sydneyService.imageUrl.value],
                            )));
                  } else {
                    // Render normal message
                    final message = controller.messages[index];
                    messageTile = MessageTile(
                      index: index,
                      message: message,
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1024),
                        child: messageTile,
                      ))
                    ],
                  );
                },
              )),
    );
  }
}
