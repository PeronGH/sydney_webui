// Copied from https://github.com/xclud/dart_download/blob/main/lib/src/html.dart
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

/// Downloads a file from a [stream] into the destination [filename].
///
/// There are a few caveats about this function:
/// - On the web it caches the contents in a [Blob](https://developer.mozilla.org/en-US/docs/Web/API/Blob) and eventually saves the file in browser's default location.
/// - On desktop it saves the file in absolute or relative path.
/// - On mobile it saves the file in absolute or relative path, but we should ask/ensure if the app has the required permissions.
/// - On the web, not supported in IE or Edge (prior version 18), or in Safari (prior version 10.1).
Future<void> download(String url, String filename) async {
  filename = filename.replaceAll('/', '_').replaceAll('\\', '_');

  // Create the link with the file
  final anchor = AnchorElement(href: url)..target = 'blank';
  // add the name
  anchor.download = filename;

  // trigger download
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
