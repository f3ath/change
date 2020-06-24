import 'package:change/src/model/collection.dart';
import 'package:change/src/model/link.dart';
import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class Release extends Collection {
  Release(this.version, this.date);

  static final regexp = RegExp(r'^(.+)\s+-\s+(\d+-\d+-\d+)$');

  static Release parse(String text) => Maybe(regexp.firstMatch(text))
      .map((_) => Release(_.group(1), _.group(2)))
      .orThrow(() => 'Unrecognized release header "$text"');

  final String version;
  final String date;

  @override
  List<Node> toMarkdown() => [Element('h2', _header), ...super.toMarkdown()];

  List<Node> get _header {
    if (link?.isNotEmpty == true) {
      return [
        Link([Text(version)], link),
        Text(' - $date')
      ];
    }
    return [Text('$version - $date')];
  }
}
