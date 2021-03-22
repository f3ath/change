import 'package:change/src/anchor.dart';
import 'package:change/src/change_set.dart';
import 'package:change/src/change_set_title.dart';
import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class Release extends ChangeSet {
  Release(this.version, {String? date}) : date = Maybe(date);

  static final _regexp = RegExp(r'^(.+)\s+-\s+(\d+-\d+-\d+)$');

  static Release parse(String text) => Maybe(_regexp.firstMatch(text))
      .map((_) => Release(_.group(1)!, date: _.group(2)))
      .orGet(() => Release(text));

  /// Release version.
  final String version;

  /// Release date.
  final Maybe<String> date;

  @override
  List<Element> toMarkdown() => [
        ChangeSetTitle(_header),
        ...super.toMarkdown(),
      ];

  List<Node> get _header => link
      .map((href) => [
            Anchor(href, [Text(version)]),
            ...date.map((date) => [Text(' - $date')]).or(const [])
          ])
      .orGet(() => [Text(version + date.map((date) => ' - $date').or(''))]);
}
