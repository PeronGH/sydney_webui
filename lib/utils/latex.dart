// Copied from https://github.com/asjqkkkk/markdown_widget/blob/dev/example/lib/markdown_custom/latex.dart

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as m;

SpanNodeGeneratorWithTag latexGenerator = SpanNodeGeneratorWithTag(
    tag: _latexTag,
    generator: (e, config, visitor) =>
        LatexNode(e.attributes, e.textContent, config));

const _latexTag = 'latex';

class LatexSyntax extends m.InlineSyntax {
  LatexSyntax() : super(r'(\$\$[\s\S]+?\$\$)|(\\\(.+?\\\))');

  @override
  bool onMatch(m.InlineParser parser, Match match) {
    final input = match.input;
    final matchValue = input.substring(match.start, match.end);
    String content = '';
    bool isInline = true;
    const blockSyntax = r'$$';
    const inlineSyntaxStart = r'\(';
    const inlineSyntaxEnd = r'\)';
    if (matchValue.startsWith(blockSyntax) &&
        matchValue.endsWith(blockSyntax) &&
        (matchValue != blockSyntax)) {
      content = matchValue.substring(2, matchValue.length - 2);
      isInline = false;
    } else if (matchValue.startsWith(inlineSyntaxStart) &&
        matchValue.endsWith(inlineSyntaxEnd) &&
        matchValue != inlineSyntaxStart) {
      content = matchValue.substring(2, matchValue.length - 2);
    }
    m.Element el = m.Element.text(_latexTag, matchValue);
    el.attributes['content'] = content;
    el.attributes['isInline'] = '$isInline';
    parser.addNode(el);
    return true;
  }
}

class LatexNode extends SpanNode {
  final Map<String, String> attributes;
  final String textContent;
  final MarkdownConfig config;

  LatexNode(this.attributes, this.textContent, this.config);

  @override
  InlineSpan build() {
    final content = attributes['content'] ?? '';
    final isInline = attributes['isInline'] == 'true';
    final style = parentStyle ?? config.p.textStyle;
    if (content.isEmpty) return TextSpan(style: style, text: textContent);
    final latex = Math.tex(
      content,
      mathStyle: MathStyle.text,
      textStyle: style,
      textScaleFactor: 1,
      onErrorFallback: (error) {
        return Text(
          textContent,
          style: style.copyWith(color: Colors.red),
        );
      },
    );
    return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: !isInline
            ? Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: latex),
              )
            : latex);
  }
}
