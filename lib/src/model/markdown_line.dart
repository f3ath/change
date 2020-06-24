import 'package:markdown/markdown.dart';

/// A single line of markdown text
class MarkdownLine {
  MarkdownLine([List<Node> nodes = const []]) {
    this.nodes.addAll(nodes);
  }

  final nodes = <Node>[];

  String get text => nodes.map((e) => e.textContent).join();
}
