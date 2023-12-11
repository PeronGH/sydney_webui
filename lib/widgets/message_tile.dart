import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:get/get.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/utils/array.dart';
import 'package:sydney_webui/widgets/code_element.dart';

class MessageTile extends StatelessWidget {
  const MessageTile(
      {Key? key, required this.message, this.editButton, this.deleteButton})
      : super(key: key);

  final Message message;
  final Widget? editButton;
  final Widget? deleteButton;

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    final shouldExpand = message.type == Message.typeMessage;

    void copyContent() async {
      try {
        await Clipboard.setData(ClipboardData(text: message.content));
        Get.snackbar('Copied',
            'Message from ${message.role} has been copied to clipboard');
      } catch (e) {
        Get.snackbar('Error Occurred', 'Failed to copy message to clipboard');
      }
    }

    final copyButton = IconButton(
      onPressed: copyContent,
      icon: const Icon(Icons.copy_rounded),
    );

    final title = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(switch (message.role) {
            Message.roleUser => Icons.person_outline,
            Message.roleAssistant => Icons.assistant_outlined,
            Message.roleSystem => Icons.info_outline,
            _ => Icons.question_mark,
          }),
          const SizedBox(width: 8),
          Text(message.type)
        ]),
        Row(
            children: switch (message.role) {
          Message.roleUser =>
            [copyButton, editButton, deleteButton].filterNonNull(),
          Message.roleAssistant => [copyButton, deleteButton].filterNonNull(),
          Message.roleSystem => [copyButton].filterNonNull(),
          _ => [],
        })
      ],
    );

    final subtitle = Padding(
      padding: const EdgeInsets.only(top: 8),
      child:
          md.MarkdownBody(selectable: true, data: message.content, builders: {
        'code': CodeElementBuilder(),
      }),
    );

    return shouldExpand
        ? ListTile(
            title: title,
            subtitle: subtitle,
            titleTextStyle: theme.textTheme.bodySmall,
          )
        : ExpansionTile(
            shape: const RoundedRectangleBorder(),
            title: title,
            children: [subtitle],
          );
  }
}
