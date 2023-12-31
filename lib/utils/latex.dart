import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:markdown/markdown.dart';

class BingLatexBlockSyntax extends LatexBlockSyntax {
  @override
  List<Line> parseChildLines(BlockParser parser) {
    final childLines = super.parseChildLines(parser);

    return [Line("\\begin{aligned}"), ...childLines, Line("\\end{aligned}")];
  }
}

class BingLatexInlineSyntax extends InlineSyntax {
  BingLatexInlineSyntax() : super(r'\${2}(.+?)\${2}');

  @override
  bool onMatch(InlineParser parser, Match match) {
    Element element = Element.text('latex', match[1] ?? '');
    element.attributes['displayMode'] = 'true';
    parser.addNode(element);
    return true;
  }
}
