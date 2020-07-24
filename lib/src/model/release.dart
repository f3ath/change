import 'package:change/src/model/collection.dart';
import 'package:change/src/model/link.dart';
import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class Release {
  Release(this.version, {String date}) : date = Maybe(date);

  static final regexp = RegExp(r'^(.+)\s+-\s+(\d+-\d+-\d+)$');

  static Release parse(String text) => Maybe(regexp.firstMatch(text))
      .map((_) => Release(_.group(1), date: _.group(2)))
      .orGet(() => Release(text));

  final String version;
  final Maybe<String> date;
  final Collection changes = Collection();
  String link = '';

  List<Node> toMarkdown() => [Element('h2', _header), ...changes.toMarkdown()];

  List<Node> get _header {
    if (link?.isNotEmpty == true) {
      return [
        Link([Text(version)], link),
        ...date.map((_) => [Text(' - $_')]).or([])
      ];
    }
    return [Text(version + date.map((_) => ' - $_').or(''))];
  }
}
