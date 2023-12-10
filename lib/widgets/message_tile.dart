import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
              Message.roleUser => [editButton, deleteButton].filterNonNull(),
              Message.roleAssistant => [deleteButton].filterNonNull(),
              Message.roleSystem => [editButton].filterNonNull(),
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
