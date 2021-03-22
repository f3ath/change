import 'package:markdown/markdown.dart';

/// A single change
class Change {
  Change(this.description);

  /// Change description as markdown nodes
  final List<Node> description;

  /// A plain text representation of the change
  @override
  String toString() => description.map((_) => _.textContent).join();

  Iterable<Node> toMarkdown() => [Element('li', description)];
}
