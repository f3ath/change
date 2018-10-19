import 'package:change/change.dart';
import 'package:change/src/keepachangelog/changelog_parser.dart';
import 'package:markdown/markdown.dart';

/// Parses a list of markdown [lines] into a [Changelog]
Changelog parser(List<String> lines) {
  final changelog = Changelog();
  final nodes = Document().parseLines(lines);
  nodes.forEach((n) {
    if (n is Element) {
      n.accept(ChangelogParser.byTag(n.tag, changelog));
    }
  });
  return changelog;
}
