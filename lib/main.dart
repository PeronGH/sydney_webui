import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sydney_webui/pages/chat_page.dart';

void main() async {
  await GetStorage.init();

  final colorIndex = Random().nextInt(Colors.primaries.length);
  final color = Colors.primaries[colorIndex];

  runApp(
    GetMaterialApp(
        title: "Sydney Chat",
        home: ChatPage(),
        theme: ThemeData(colorSchemeSeed: color, brightness: Brightness.light),
        darkTheme:
            ThemeData(colorSchemeSeed: color, brightness: Brightness.dark)),
  );
}
