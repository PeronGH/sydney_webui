import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sydney_webui/utils/copy.dart';
import 'package:sydney_webui/utils/string.dart';

class CodeElement extends StatelessWidget {
  const CodeElement({super.key, this.language = "", this.textContent = ""});

  final String language;
  final String textContent;

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16),

              // Specify text style
              textStyle: GoogleFonts.robotoMono(),

              // Specify tab size
              tabSize: 4,
            ))
      ],
    );
  }
}
