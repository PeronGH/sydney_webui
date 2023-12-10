import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/utils/array.dart';

class MessageTile extends StatelessWidget {
  const MessageTile(
      {Key? key, required this.message, this.editButton, this.deleteButton})
      : super(key: key);

  final Message message;
  final Widget? editButton;
  final Widget? deleteButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final markdownTheme = MarkdownStyleSheet.fromTheme(theme).copyWith(
        code: theme.textTheme.bodyMedium!
            .copyWith(fontFamily: GoogleFonts.robotoMono().fontFamily));

    void copyContent() async {
      await Clipboard.setData(ClipboardData(text: message.content));
      Get.snackbar('Copied',
          'Message from ${message.role} has been copied to clipboard');
    }

    final copyButton = IconButton(
      onPressed: copyContent,
      icon: const Icon(
        Icons.copy,
        size: 20,
      ),
    );

    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
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
              Message.roleAssistant =>
                [copyButton, deleteButton].filterNonNull(),
              Message.roleSystem => [copyButton, editButton].filterNonNull(),
              _ => [],
            })
          ],
        ),
      ),
      subtitle: MarkdownBody(
        selectable: true,
        data: message.content,
        styleSheet: markdownTheme,
      ),
      titleTextStyle: theme.textTheme.bodySmall,
    );
  }
}
