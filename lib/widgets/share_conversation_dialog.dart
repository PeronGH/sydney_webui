import 'package:flutter/material.dart';
import 'package:sydney_webui/utils/copy.dart';
import 'package:sydney_webui/utils/url.dart';
import 'package:share_plus/share_plus.dart';

class ShareConversationDialog extends StatelessWidget {
  final String sharegptUrl;

  const ShareConversationDialog({super.key, required this.sharegptUrl});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Conversation'),
      content: SelectableText(sharegptUrl),
      actions: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ElevatedButton(
                  onPressed: () => copyContent(sharegptUrl),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded),
                      SizedBox(width: 8),
                      Text('Copy')
                    ],
                  )),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () => openUrl(sharegptUrl),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_browser_rounded),
                      SizedBox(width: 8),
                      Text('Open')
                    ],
                  )),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () => Share.share(sharegptUrl),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_outlined),
                      SizedBox(width: 8),
                      Text('Share')
                    ],
                  ))
            ],
          ),
        )
      ],
    );
  }
}
