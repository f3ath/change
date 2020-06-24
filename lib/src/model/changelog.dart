import 'package:change/model.dart';
import 'package:change/src/model/collection.dart';
import 'package:change/src/model/link_finder.dart';
import 'package:change/src/model/markdown_line.dart';
import 'package:change/src/model/release.dart';
import 'package:change/src/model/unreleased.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart';
import 'package:marker/marker.dart';

class Changelog {
  /// The text just below the title.
  final header = <Element>[];

  /// A list of releases.
  final releases = <Release>[];

  /// Unreleased changes.
  final unreleased = Unreleased();

  /// Rendered markdown text.
  String dump() => render([
        ...header,
        ...unreleased.toMarkdown(),
        ...releases.reversed.map((_) => _.toMarkdown()).expand((_) => _),
      ], flavor: changelog);

  /// Creates an instance from markdown nodes.
  static Changelog fromMarkdown(List<Node> nodes) {
    final changelog = Changelog();
    var atHeader = true;
    Collection collection;
    ChangeType type;
    final releases = <Release>[];
    for (final node in nodes) {
      if (node is Element) {
        final text = node.textContent;
        if (node.tag == 'h2') {
          atHeader = false;
          if (text.trim().toLowerCase() == 'unreleased') {
            collection = changelog.unreleased;
          } else {
            releases.add(Release.parse(text));
            collection = releases.last;
          }
          final finder = LinkFinder();
          node.accept(finder);
          if (finder.links.isNotEmpty) {
            collection.link = finder.links.first;
          }
        } else if (atHeader) {
          changelog.header.add(node);
        } else if (node.tag == 'h3') {
          type = ChangeType.fromString(text);
        } else if (node.tag == 'ul') {
          node.children.forEach((child) {
            if (child is Element) {
              collection.add(type, MarkdownLine(child.children));
            }
          });
        }
      }
    }
    changelog.releases.addAll(releases.reversed);
    return changelog;
  }

  /// "Releases" all unreleased changes with the [targetVersion] and [date], namely
  /// - adds new release to the top of the list
  /// - copies all unreleased changes to it
  /// - clears the "Unreleased" section
  /// - optionally generates/updates the diff links
  /// The [diff] link template must use `%from%` and `%to%` as version placeholders,
  /// example: `https://github.com/example/project/compare/%from%...%to%`
  void release(String targetVersion, String date, {String diff}) {
    final latestVersion = releases.last.version;
    final release = Release(targetVersion, date)..copyChangesFrom(unreleased);
    releases.add(release);
    unreleased.clearChanges();
    if (diff != null) {
      release.link = _format(diff, latestVersion, targetVersion);
      unreleased.link = _format(diff, targetVersion, 'HEAD');
    }
  }

  String _format(String template, String from, String to) =>
      template.replaceAll('%from%', from).replaceAll('%to%', to);
}
