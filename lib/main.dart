import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sydney_webui/pages/chat_page.dart';

void main() async {
  await GetStorage.init();
  runApp(
    GetMaterialApp(
        home: ChatPage(),
        theme: ThemeData(
            colorSchemeSeed: Colors.teal, brightness: Brightness.light),
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal, brightness: Brightness.dark)),
  );
}
