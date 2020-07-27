import 'package:change/src/anchor.dart';
import 'package:change/src/change_set.dart';
import 'package:markdown/markdown.dart';

import 'change_set_title.dart';

/// The `Unreleased` section of the changelog.
class Unreleased extends ChangeSet {
  @override
  List<Element> toMarkdown() => [
        ChangeSetTitle([
          (link.map<Node>((href) => Anchor(href, [_title])).or(_title))
        ]),
        ...super.toMarkdown()
      ];

  static final _title = Text('Unreleased');
}
