import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sydney_webui/controller.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/utils/copy.dart';
import 'package:sydney_webui/utils/latex.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:sydney_webui/utils/url.dart';
import 'package:sydney_webui/widgets/image_table.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.index,
    this.isBeingGenerated = false,
  });

  final Message message;
  final int index;
  final bool isBeingGenerated;

  List<String> parseSuggestedResponses(String content) {
    try {
      final responses = jsonDecode(content) as List<dynamic>;
      return responses.cast<String>().toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    final shouldExpand = message.role != Message.roleSystem;

    final copyButton = IconButton(
      onPressed: () => copyContent(message.content),
      icon: const Icon(Icons.copy_rounded),
    );

    final deleteButton = Obx(() => IconButton(
          onPressed: controller.isGenerating.value
              ? null
              : () => controller.deleteMessageAt(index),
          icon: const Icon(Icons.delete_outline),
        ));

    final editButton = Obx(() => IconButton(
          onPressed: controller.isGenerating.value
              ? null
              : () => controller.editMessageAt(index),
          icon: const Icon(Icons.edit_outlined),
        ));

    final List<Widget> actions = isBeingGenerated
        ? []
        : switch (message.role) {
            Message.roleUser => [copyButton, editButton, deleteButton],
            Message.roleAssistant => [copyButton, deleteButton],
            Message.roleSystem => [copyButton],
            _ => []
          };

    final List<Widget> typeSpecificContent = switch (message.type) {
      Message.typeSuggestedResponses => [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: parseSuggestedResponses(message.content)
                      .map((response) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () => controller.setPrompt(response),
                              child: Text(response))))
                      .toList()))
        ],
      _ => []
    };

    final images = message.imageUrls != null && message.imageUrls!.isNotEmpty
        ? [ImageTable.fromImageUrls(message.imageUrls!)]
        : [];

    return ExpansionTile(
      shape: const RoundedRectangleBorder(),
      maintainState: true,
      title: Row(
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
          Row(children: actions)
        ],
      ),
      initiallyExpanded: shouldExpand,
      expandedAlignment: Alignment.topLeft,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        MarkdownBlock(
          data: message.content,
          generator: MarkdownGenerator(
              inlineSyntaxList: [LatexSyntax()], generators: [latexGenerator]),
          config: MarkdownConfig(configs: [
            PreConfig(
              builder: (code, language) => Container(
                decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language.isEmpty ? 'code' : language,
                              style: GoogleFonts.robotoMono()
                                  .copyWith(color: Colors.grey[400])),
                          IconButton(
                            onPressed: () => copyContent(code),
                            icon: const Icon(Icons.copy_rounded),
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: HighlightView(
                          code,
                          language: language,
                          theme: atomOneDarkTheme,
                          textStyle: GoogleFonts.robotoMono(),
                          tabSize: 4,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        ))
                  ],
                ),
              ),
            ),
            CodeConfig(style: GoogleFonts.robotoMono()),
            const LinkConfig(
                onTap: openUrl, style: TextStyle(color: Colors.blue))
          ]),
        ),
        ...typeSpecificContent,
        ...images
      ],
    );
  }
}
