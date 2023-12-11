import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final brightness = Get.theme.brightness;

    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // https://stackoverflow.com/questions/59592640/how-to-add-code-syntax-highlighter-to-flutter-markdown
      child: HighlightView(
        // The original code to be highlighted
        element.textContent,

        // Specify language
        // It is recommended to give it a value for performance
        language: language,

        // Specify highlight theme
        // All available themes are listed in `themes` folder
        theme: brightness == Brightness.light
            ? atomOneLightTheme
            : atomOneDarkTheme,

        // Specify padding
        padding: const EdgeInsets.all(8),

        // Specify text style
        textStyle: GoogleFonts.robotoMono(),

        // Specify tab size
        tabSize: 4,
      ),
    );
  }
}
