import 'package:change/src/change.dart';
import 'package:markdown/markdown.dart';

abstract class Section {
  static Map<String, List<Change>> groups(Section section) => {
        'Added': section.added,
        'Changed': section.changed,
        'Deprecated': section.deprecated,
        'Fixed': section.fixed,
        'Removed': section.removed,
        'Security': section.security
      };

  final added = <Change>[];
  final changed = <Change>[];
  final deprecated = <Change>[];
  final fixed = <Change>[];
  final removed = <Change>[];
  final security = <Change>[];
  
  void setFrom(Section other) {
    final my = groups(this);
    groups(other).entries.forEach((_) {
      my[_.key]!.clear();
      my[_.key]!.addAll(_.value);
    });
  }

  Iterable<Node> toMarkdown() =>
      groups(this).entries.where((_) => _.value.isNotEmpty).expand((_) => [
            Element('h3', [Text(_.key)]),
            Element('ul', _.value.expand((_) => _.toMarkdown()).toList())
          ]);
}
