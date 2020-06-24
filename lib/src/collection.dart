import 'package:change/src/change_type.dart';
import 'package:change/src/markdown_line.dart';
import 'package:markdown/markdown.dart';

class Collection {
  final Map<ChangeType, List<MarkdownLine>> _map =
      Map.fromIterable(ChangeType.all, value: (_) => <MarkdownLine>[]);
  String link = '';

  void add(ChangeType kind, MarkdownLine MarkdownLine) {
    _map[kind].add(MarkdownLine);
  }

  /// Copies all changes from the [source] collection.
  void copyChangesFrom(Collection source) {
    _map.forEach((type, list) {
      list.addAll(source._map[type]);
    });
  }

  /// Clears all changes
  void clearChanges() {
    _map.values.forEach((element) {
      element.clear();
    });
  }

  List<MarkdownLine> get(ChangeType kind) => _map[kind];

  List<Node> toMarkdown() => _map.entries
      .map((_) => _.value.isNotEmpty
          ? [_title(_.key.name), _entries(_.value)]
          : <Element>[])
      .expand((_) => _)
      .toList();

  Element _title(String text) => Element('h3', [Text(text)]);

  Element _entries(List<MarkdownLine> entries) =>
      Element('ul', entries.map((_) => Element('li', _.nodes)).toList());
}
