import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sydney_webui/utils/url.dart';
import 'package:share_plus/share_plus.dart';

class ShareConversationDialog extends StatelessWidget {
  final String sharegptUrl;

  const ShareConversationDialog({super.key, required this.sharegptUrl});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Conversation'),
      content: Text(sharegptUrl),
      actions: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sharegptUrl));
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.copy_rounded), Text('Copy')],
                  )),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () {
                    openUrl(sharegptUrl);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_browser_rounded),
                      Text('Open')
                    ],
                  )),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () {
                    Share.share(sharegptUrl);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.share_rounded), Text('Share')],
                  ))
            ],
          ),
        )
      ],
    );
  }
}
