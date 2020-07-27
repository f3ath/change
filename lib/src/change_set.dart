import 'package:change/src/change_type.dart';
import 'package:change/src/section.dart';
import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// A set of changes.
class ChangeSet {
  /// Copies all changes from the [source] collection.
  void copyFrom(ChangeSet source) {
    _map.forEach((type, list) {
      list.addAll(source._map[type]);
    });
  }

  /// Clears all sections
  void clear() {
    _map.values.forEach((element) {
      element.clear();
    });
  }

  /// The `Added` section
  Section get added => _map[ChangeType.addition];

  /// The `Changed` section
  Section get changed => _map[ChangeType.change];

  /// the `Deprecated` section
  Section get deprecated => _map[ChangeType.deprecation];

  /// The `Fixed` section
  Section get fixed => _map[ChangeType.fix];

  /// The `Removed` section
  Section get removed => _map[ChangeType.removal];

  /// The `Security` section
  Section get security => _map[ChangeType.security];

  /// The change section of the given [type]
  Section section(ChangeType type) => _map[type];

  List<Node> toMarkdown() => _map.values
      .where((_) => _.isNotEmpty)
      .map((_) => _.toMarkdown())
      .expand((_) => _)
      .toList();

  /// The diff link.
  Maybe<String> get link => Maybe(_link);

  /// Sets the diff link.
  void setLink(String link) {
    _link = link;
  }

  /// Removes the diff link.
  void removeLink() {
    _link = null;
  }

  String _link;

  final Map<ChangeType, Section> _map =
      Map.fromIterable(ChangeType.all, value: (_) => Section(_));
}
