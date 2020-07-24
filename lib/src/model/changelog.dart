import 'package:change/model.dart';
import 'package:change/src/model/collection.dart';
import 'package:change/src/model/link_finder.dart';
import 'package:change/src/model/link_template.dart';
import 'package:change/src/model/markdown_line.dart';
import 'package:change/src/model/release.dart';
import 'package:change/src/model/unreleased.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart';
import 'package:marker/marker.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:pub_semver/pub_semver.dart';

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

  /// Creates an instance from lines of text.
  static Changelog fromLines(List<String> text) =>
      fromMarkdown(Document().parseLines(text));

  /// Creates an instance from markdown nodes.
  static Changelog fromMarkdown(List<Node> nodes) {
    final changelog = Changelog();
    var atHeader = true;
    Collection collection;
    var type = ChangeType.change;
    final releases = <Release>[];
    for (final node in nodes) {
      if (node is Element) {
        final text = node.textContent;
        if (node.tag == 'h2') {
          atHeader = false;
          final finder = LinkFinder();
          node.accept(finder);
          if (text.trim().toLowerCase() == 'unreleased') {
            if (finder.links.isNotEmpty) {
              changelog.unreleased.link = finder.links.first;
            }
            collection = changelog.unreleased.changes;
          } else {
            releases.add(Release.parse(text));
            collection = releases.last.changes;
            if (finder.links.isNotEmpty) {
              releases.last.link = finder.links.first;
            }
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

  /// "Releases" all unreleased changes with the [version] and [date], namely
  /// - adds new release to the top of the list
  /// - copies all unreleased changes to it
  /// - clears the "Unreleased" section
  /// - optionally generates/updates the diff links
  /// The [link] template must use `%from%` and `%to%` as version placeholders,
  /// example: `https://github.com/example/project/compare/%from%...%to%`
  void release(String version, String date, {String link}) {
    final release = Release(version, date)
      ..changes.copyFrom(unreleased.changes);
    final previous = _findPredecessor(version);
    releases.add(release);
    unreleased.changes.clear();

    if (link != null) {
      final template = LinkTemplate(link);
      unreleased.link = template.format(version, 'HEAD');
      previous.ifPresent((_) {
        release.link = template.format(_, version);
      });
    }else {
      unreleased.link = '';
    }
  }

  Maybe<String> _findPredecessor(String version) {
    if (releases.isEmpty) return Nothing();
    final target = Version.parse(version);
    final versions = releases.map((release) => Version.parse(release.version));
    Version candidate;
    for (final v in versions) {
      if (v < target && (candidate == null || candidate < v)) {
        candidate = v;
      }
    }
    return Maybe(candidate).map((_) => _.toString());
  }
}
