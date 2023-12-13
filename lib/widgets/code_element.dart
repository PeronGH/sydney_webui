import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final textContent = element.textContent;

    var language = '';

    if (element.attributes['class']?.startsWith('language-') ?? false) {
      String lg = element.attributes['class'] as String;
      language = lg.substring('language-'.length);
    }

    if (language.isEmpty && !textContent.contains("\n")) {
      // handle inline code
      return Text("`$textContent`", style: GoogleFonts.robotoMono());
    }

    void copyContent() async {
      try {
        await Clipboard.setData(ClipboardData(text: textContent));
        Get.snackbar('Copied', 'Code has been copied to clipboard');
      } catch (e) {
        Get.snackbar(
            'Error Occurred', 'Failed to copy message to clipboard: $e');
      }
    }

    // render code block
    return Column(
      children: [
        Container(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(language.isEmpty ? 'code' : language,
                    style: GoogleFonts.robotoMono()),
                IconButton(
                    onPressed: copyContent,
                    icon: const Icon(Icons.copy_rounded)),
              ],
            ),
          ),
        ),
        // https://stackoverflow.com/questions/59592640/how-to-add-code-syntax-highlighter-to-flutter-markdown
        SizedBox(
            width: double.infinity,
            child: HighlightView(
              // The original code to be highlighted
              textContent.trim(),

              // Specify language
              // It is recommended to give it a value for performance
              language: language,

              // Specify highlight theme
              theme: atomOneDarkTheme,

              // Specify padding
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              // Specify text style
              textStyle: GoogleFonts.robotoMono(),

              // Specify tab size
              tabSize: 4,
            ))
      ],
    );
  }
}
