import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:sydney_webui/controller.dart';
import 'package:sydney_webui/models/message.dart';
import 'package:sydney_webui/utils/latex.dart';
import 'package:sydney_webui/utils/url.dart';
import 'package:sydney_webui/widgets/code_element.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({
    Key? key,
    required this.message,
    required this.index,
    this.isBeingGenerated = false,
  }) : super(key: key);

  final Message message;
  final int index;
  final bool isBeingGenerated;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<Controller>();

    final shouldExpand = message.role != Message.roleSystem;

    void copyContent() async {
      try {
        await Clipboard.setData(ClipboardData(text: message.content));
        Get.snackbar('Copied',
            'Message from ${message.role} has been copied to clipboard');
      } catch (e) {
        Get.snackbar(
            'Error Occurred', 'Failed to copy message to clipboard: $e');
      }
    }

    final copyButton = IconButton(
      onPressed: copyContent,
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

    List<String> parseSuggestedResponses(String content) {
      try {
        final responses = jsonDecode(content) as List<dynamic>;
        return responses.cast<String>().toList();
      } catch (_) {
        return [];
      }
    }

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
        ? [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: message.imageUrls!
                      .map((url) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 256),
                              child: Column(
                                children: [
                                  Image.network(url),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                      onPressed: () => openUrl(url),
                                      child: const Text('View'))
                                ],
                              ))))
                      .toList(),
                ))
          ]
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
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        md.MarkdownBody(
            selectable: true,
            data: message.content,
            extensionSet: md.ExtensionSet([
              ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
              BingLatexBlockSyntax()
            ], [
              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
              BingLatexInlineSyntax()
            ]),
            onTapLink: (text, href, title) {
              if (href != null) openUrl(href);
            },
            builders: {
              'code': CodeElementBuilder(),
              'latex': LatexElementBuilder(),
            }),
        ...typeSpecificContent,
        ...images
      ],
    );
  }
}
