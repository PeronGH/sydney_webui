import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class ImageTable extends StatelessWidget {
  const ImageTable({super.key, required this.tableContent});

  factory ImageTable.fromImageUrls(List<String> imageUrls) {
    final buf = StringBuffer();

    buf.write("|");
    for (final url in imageUrls) {
      buf.write("![image]($url)|");
    }

    buf.write("\n|");
    for (final _ in imageUrls) {
      buf.write(":---:|");
    }

    buf.write("\n|");
    for (final url in imageUrls) {
      buf.write("[Download]($url)|");
    }

    return ImageTable(tableContent: buf.toString());
  }

  final String tableContent;

  @override
  Widget build(BuildContext context) {
    return MarkdownBlock(data: tableContent);
  }
}
