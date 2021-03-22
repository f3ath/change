import 'package:change/src/anchor.dart';
import 'package:change/src/change_set.dart';
import 'package:markdown/markdown.dart';

import 'change_set_title.dart';

/// The `Unreleased` section of the changelog.
class Unreleased extends ChangeSet {
  @override
  List<Element> toMarkdown() {
    final changes = super.toMarkdown();
    if (changes.isEmpty) return [];
    return [
      ChangeSetTitle([
        (link.map<Node>((href) => Anchor(href, [_title])).or(_title))
      ]),
      ...changes
    ];
  }

  static final _title = Text('Unreleased');
}
