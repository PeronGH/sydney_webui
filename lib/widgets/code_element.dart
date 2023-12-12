import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
      return Text("`$textContent`",
          style: preferredStyle?.copyWith(
              fontFamily: GoogleFonts.robotoMono().fontFamily));
    }

    // render code block
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // https://stackoverflow.com/questions/59592640/how-to-add-code-syntax-highlighter-to-flutter-markdown
      child: HighlightView(
        // The original code to be highlighted
        textContent,

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
      ),
    );
  }
}
