import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';
import 'package:sydney_webui/utils/copy.dart';
import 'package:sydney_webui/utils/string.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final textContent = element.textContent;

    if (!textContent.endsWith("\n")) {
      // handle inline code
      return Text("`$textContent`", style: GoogleFonts.robotoMono());
    }

    var language = '';

    if (element.attributes['class']?.startsWith('language-') ?? false) {
      String lg = element.attributes['class'] as String;
      language = lg.substring('language-'.length);
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
                    style: GoogleFonts.robotoMono()
                        .copyWith(color: Colors.grey[400])),
                IconButton(
                  onPressed: () => copyContent(textContent),
                  icon: const Icon(Icons.copy_rounded),
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        // https://stackoverflow.com/questions/59592640/how-to-add-code-syntax-highlighter-to-flutter-markdown
        SizedBox(
            width: double.infinity,
            child: HighlightView(
              // The original code to be highlighted
              textContent.removeSuffix('\n'),

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
