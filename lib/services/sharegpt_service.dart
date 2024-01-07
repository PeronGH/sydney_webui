import 'package:get/get.dart';
import 'package:sydney_webui/models/message.dart';

class ShareGptService extends GetConnect {
  Future<String> uploadConversation(List<Message> messages) async {
    final items = messages
        .map((msg) => switch (msg) {
              Message(
                role: Message.roleUser,
                type: Message.typeMessage,
                content: _
              ) =>
                {"from": "user", "value": msg.content},
              Message(
                role: Message.roleAssistant,
                type: Message.typeMessage,
                content: _
              ) =>
                {"from": "gpt", "value": msg.content},
              _ => null
            })
        .where((e) => e != null)
        .cast<Map<String, String>>()
        .toList();

    if (items.isEmpty) throw Exception("No message to upload");

    final response =
        await post("https://sharegpt.com/api/conversations", {"items": items});

    return response.body["id"];
  }
}
