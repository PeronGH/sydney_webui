import 'package:flutter/material.dart';
import 'package:sydney_webui/utils/copy.dart';
import 'package:sydney_webui/utils/url.dart';

class ShareConversationDialog extends StatelessWidget {
  final String shareGptUrl;

  const ShareConversationDialog({Key? key, required this.shareGptUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("ShareGPT URL"),
      content: SingleChildScrollView(
        child: ListBody(children: [
          SelectableText(shareGptUrl),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () => copyContent(shareGptUrl),
                tooltip: "Copy URL",
              ),
              IconButton(
                icon: const Icon(Icons.open_in_browser_rounded),
                onPressed: () => openUrl(shareGptUrl),
                tooltip: "Open URL",
              )
            ],
          )
        ]),
      ),
    );
  }
}
