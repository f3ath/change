import 'package:markdown/markdown.dart';

/// Inline markdown text
class InlineMarkdown {
  InlineMarkdown([Iterable<Node> nodes = const []]) {
    _nodes.addAll(nodes);
  }

  static InlineMarkdown parse(String text) =>
      InlineMarkdown(Document().parseInline(text));

  final _nodes = <Node>[];

  @override
  String toString() => _nodes.map((e) => e.textContent).join();

  List<Node> toMarkdown() => _nodes.toList();
}
