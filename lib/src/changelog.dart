import 'dart:collection';

import 'package:change/src/change.dart';
import 'package:change/src/link_collector.dart';
import 'package:change/src/release.dart';
import 'package:change/src/unreleased.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart';
import 'package:marker/marker.dart';
import 'package:pub_semver/pub_semver.dart';

/// A changelog
class Changelog {
  /// Reads the changelog from markdown [lines].
  static Changelog fromMarkdown(List<String> lines) =>
      _fromMarkdown(Document().parseLines(lines));

  final _releases = SplayTreeMap<Version, Release>();

  /// The header at the top
  final header = <Node>[];

  /// The unreleased section
  final unreleased = Unreleased();

  /// Releases ordered by version (lower to higher)
  Iterable<Release> get releases => _releases.values;

  /// Finds the latest release. If [lessThan] is provided, it will be used as
  /// the exclusive upper boundary.
  Release? latest({Version? lessThan}) {
    final filtered = lessThan == null
        ? releases
        : releases.where((r) => r.version.compareTo(lessThan) < 0);
    if (filtered.isEmpty) return null;
    return filtered.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  /// The changelog as markdown nodes
  Iterable<Node> toMarkdown() sync* {
    yield* header;
    yield* unreleased.toMarkdown();
    yield* releases.toList().reversed.expand((r) => r.toMarkdown());
  }

  String toText() => render(toMarkdown(), flavor: changelog);

  /// "Releases" all unreleased changes with the [version] and [date], namely
  /// - adds new release to the list
  /// - copies all unreleased changes to it
  /// - clears the "Unreleased" section
  /// - optionally generates/updates the diff links
  /// The [linkTemplate] must use `%from%` and `%to%` as version placeholders,
  /// example: `https://github.com/example/project/compare/%from%...%to%`
  void release(String version, String date, {String? linkTemplate}) {
    final release = Release(version, date);
    if (linkTemplate != null) {
      final previous = releases.where((r) => r.version < release.version);
      if (previous.isNotEmpty) {
        release.diff = linkTemplate
            .replaceAll('%from%', previous.last.version.toString())
            .replaceAll('%to%', release.version.toString());
      }
      unreleased.diff = linkTemplate
          .replaceAll('%from%', release.version.toString())
          .replaceAll('%to%', 'HEAD');
    }
    release.changes.addAll(unreleased.changes);
    unreleased.changes.clear();
    add(release);
  }

  void add(Release release) {
    _releases[release.version] = release;
  }

  /// Returns the release by version or throws a [StateError]
  Release get(String version) =>
      _releases[Version.parse(version)] ??
      (throw StateError('Version $version not found'));
}

Changelog _fromMarkdown(List<Node> nodes) {
  final changelog = Changelog();
  final sections = <List<Element>>[];
  for (final node in nodes.whereType<Element>()) {
    if (node.tag == 'h2') {
      sections.add([node]);
    } else if (sections.isEmpty) {
      changelog.header.add(node);
    } else {
      sections.last.add(node);
    }
  }
  sections.forEach((nodes) {
    final links = LinkCollector();
    nodes.first.accept(links);
    if (nodes.first.textContent.trim().toLowerCase() == 'unreleased') {
      changelog.unreleased.changes.addAll(_changes(nodes.skip(1)));
      if (links.isNotEmpty) changelog.unreleased.diff = links.first;
    } else {
      final release = _release(nodes);
      changelog.add(release);
      if (links.isNotEmpty) release.diff = links.first;
    }
  });

  return changelog;
}

Release _release(List<Element> nodes) {
  final title = nodes.first.textContent.trim();
  final parts = title.split(' - ');
  final release = Release(parts.first, parts.last);
  release.changes.addAll(_changes(nodes.skip(1)));
  return release;
}

Iterable<Change> _changes(Iterable<Element> nodes) sync* {
  var type = 'Change';
  for (final node in nodes) {
    if (node.tag == 'h3') {
      type = node.textContent.trim();
    } else if (node.tag == 'ul') {
      yield* node.children!
          .whereType<Element>()
          .map((node) => Change(type, node.children!));
    } else {
      throw StateError('Unexpected node ${node.tag}');
    }
  }
}
