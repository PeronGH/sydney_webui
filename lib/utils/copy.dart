import 'package:flutter/services.dart';
import 'package:get/get.dart';

Future<void> copyContent(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('Copied', 'Content has been copied to clipboard');
  } catch (e) {
    Get.snackbar('Error Occurred', 'Failed to copy to clipboard: $e');
  }
}
