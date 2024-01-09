import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sydney_webui/utils/url.dart';
import 'package:share_plus/share_plus.dart';

class ShareConversationDialog extends StatelessWidget {
    final String sharegptUrl;

    const ShareConversationDialog({Key? key, required this.sharegptUrl}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return AlertDialog(
            title: Text('Share Conversation'),
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
                          children: [
                              Icon(Icons.copy),
                              Text('Copy')
                          ],
                        ) 
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: () {
                            openUrl(sharegptUrl);
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              Icon(Icons.open_in_browser),
                              Text('Open')
                          ],
                        )
                    ), 
                    SizedBox(width: 8),
                    ElevatedButton(
                        onPressed: () {
                            Share.share(sharegptUrl);
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              Icon(Icons.share),
                              Text('Share')
                          ],
                        )
                    )
                  ],
                ),
              )
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       ElevatedButton(
                //           onPressed: () {
                //               Clipboard.setData(ClipboardData(text: sharegptUrl));
                //           },
                //           child: const Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //                 Icon(Icons.copy),
                //                 Text('Copy')
                //             ],
                //           ) 
                //       ),
                //       // SizedBox(height: 8),
                //       ElevatedButton(
                //           onPressed: () {
                //               openUrl(sharegptUrl);
                //           },
                //           child: const Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //                 Icon(Icons.open_in_browser),
                //                 Text('Open')
                //             ],
                //           )
                //       ), 
                //       // SizedBox(height: 8),
                //       ElevatedButton(
                //           onPressed: () {
                //               Share.share(sharegptUrl);
                //           },
                //           child: const Row(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //                 Icon(Icons.share),
                //                 Text('Share')
                //             ],
                //           )
                //       )
              
                // ElevatedButton(
                //     onPressed: () {
                //         Clipboard.setData(ClipboardData(text: sharegptUrl));
                //     },
                //     child: const Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //           Icon(Icons.copy),
                //           Text('Copy')
                //       ],
                //     ) 
                // ),
                // // SizedBox(height: 8),
                // ElevatedButton(
                //     onPressed: () {
                //         openUrl(sharegptUrl);
                //     },
                //     child: const Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //           Icon(Icons.open_in_browser),
                //           Text('Open')
                //       ],
                //     )
                // ), 
                // // SizedBox(height: 8),
                // ElevatedButton(
                //     onPressed: () {
                //         Share.share(sharegptUrl);
                //     },
                //     child: const Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //           Icon(Icons.share),
                //           Text('Share')
                //       ],
                //     )
                // )
            ],
        );
    }
}
