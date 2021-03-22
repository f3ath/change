import 'package:change/src/change_type.dart';
import 'package:change/src/section.dart';
import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// A set of changes.
class ChangeSet {
  /// Copies all changes from the [source] collection.
  void copyFrom(ChangeSet source) {
    _map.forEach((type, list) {
      list.addAll(source.section(type));
    });
  }

  /// Clears all sections
  void clear() {
    _map.values.forEach((element) {
      element.clear();
    });
  }

  /// The `Added` section
  Section get added => section(ChangeType.addition);

  /// The `Changed` section
  Section get changed => section(ChangeType.change);

  /// the `Deprecated` section
  Section get deprecated => section(ChangeType.deprecation);

  /// The `Fixed` section
  Section get fixed => section(ChangeType.fix);

  /// The `Removed` section
  Section get removed => section(ChangeType.removal);

  /// The `Security` section
  Section get security => section(ChangeType.security);

  /// The change section of the given [type]
  Section section(ChangeType type) => _map[type]!;

  List<Element> toMarkdown() => _map.values
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

  String? _link;

  final Map<ChangeType, Section> _map =
      Map.fromEntries(ChangeType.all.map((_) => MapEntry(_, Section(_))));
}
