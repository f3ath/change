import 'package:change/changelog.dart';
import 'package:change/src/change_set.dart';
import 'package:change/src/inline_markdown.dart';
import 'package:change/src/link_finder.dart';
import 'package:change/src/link_template.dart';
import 'package:change/src/release.dart';
import 'package:change/src/unreleased.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart';
import 'package:marker/marker.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:pub_semver/pub_semver.dart';

class Changelog {
  /// Creates an instance from lines of text.
  static Changelog fromLines(List<String> text) =>
      fromMarkdown(Document().parseLines(text));

  /// Creates an instance from markdown nodes.
  static Changelog fromMarkdown(List<Node> nodes) {
    final changelog = Changelog();
    var atHeader = true;
    ChangeSet collection;
    var type = ChangeType.change;
    final releases = <Release>[];
    for (final node in nodes) {
      if (node is Element) {
        final text = node.textContent;
        if (node.tag == 'h2') {
          atHeader = false;
          final links = LinkCollector();
          node.accept(links);
          if (text.trim().toLowerCase() == 'unreleased') {
            if (links.isNotEmpty) {
              changelog.unreleased.setLink(links.first);
            }
            collection = changelog.unreleased;
          } else {
            releases.add(Release.parse(text));
            collection = releases.last;
            if (links.isNotEmpty) {
              releases.last.setLink(links.first);
            }
          }
        } else if (atHeader) {
          changelog._header.add(node);
        } else if (node.tag == 'h3') {
          type = ChangeType.fromString(text);
        } else if (node.tag == 'ul') {
          node.children.forEach((child) {
            if (child is Element) {
              collection
                  .section(type)
                  .addMarkdown(InlineMarkdown(child.children));
            }
          });
        }
      }
    }
    changelog.releases.addAll(releases.reversed);
    return changelog;
  }

  final _header = <Element>[];

  /// The text on the top.
  Iterable<Element> get header => _header;

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

  /// "Releases" all unreleased changes with the [version] and [date], namely
  /// - adds new release to the top of the list
  /// - copies all unreleased changes to it
  /// - clears the "Unreleased" section
  /// - optionally generates/updates the diff links
  /// The [link] template must use `%from%` and `%to%` as version placeholders,
  /// example: `https://github.com/example/project/compare/%from%...%to%`
  void release(String version, String date, {String link}) {
    final release = Release(version, date: date)..copyFrom(unreleased);
    final previous = precedingVersion(version);
    releases.add(release);
    unreleased.clear();

    if (link != null) {
      final template = LinkTemplate(link);
      unreleased.setLink(template.format(version, 'HEAD'));
      previous.ifPresent((_) {
        release.setLink(template.format(_, version));
      });
    } else {
      unreleased.removeLink();
    }
  }

  /// Sets the changelog header.
  /// Must NOT contain any h2 or h3 elements as they are used in release sections.
  void setHeader(Iterable<Element> markdown) {
    if (markdown.any((element) => const ['h2', 'h3'].contains(element.tag))) {
      throw FormatException('Header may not contain h2 or h3');
    }
    _header.clear();
    _header.addAll(markdown);
  }

  /// Finds the version which precedes the [version].
  Maybe<String> precedingVersion(String version) {
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
