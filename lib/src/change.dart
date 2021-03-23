import 'package:markdown/markdown.dart';

/// A single change
class Change {
  Change(this.type, Iterable<Node> description) {
    if (type.trim().isEmpty) throw ArgumentError('Empty type');
    this.description.addAll(description);
  }

  /// Change description
  final description = <Node>[];

  /// Change type
  final String type;

  /// Change description in plain text
  @override
  String toString() => description.map((e) => e.textContent).join();
}
