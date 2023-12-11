// Inspired by https://github.com/xclud/dart_download/blob/main/lib/src/html.dart
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

Future<void> openUrl(String url) async {
  // Create the link with the file
  final anchor = AnchorElement(href: url)..target = 'blank';

  // trigger download
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
