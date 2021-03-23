import 'dart:convert';

import 'package:change/src/change.dart';
import 'package:change/src/release.dart';
import 'package:change/src/section.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart' as flavors;
import 'package:marker/marker.dart';

class Changelog {
  /// Parses the changelog from a markdown text
  static Changelog parse(String markdown) => const _Reader().read(markdown);

  /// Releases mapped by version
  final _releases = <String, Release>{};

  /// Changelog header which comes on top of the file before the Unreleased
  /// and version sections.
  final header = <Node>[];

  /// The unreleased changes.
  final unreleased = Section();

  /// All releases in chronological order (oldest first)
  Iterable<Release> history() {
    final releases = _releases.values.toList();
    releases.sort();
    return releases;
  }

  /// Returns the release by version or throws [StateError]
  Release get(String version) =>
      _releases[version.trim().toLowerCase()] ??
      (throw StateError('Version $version not found'));

  /// Returns `true` if the [version] exists in the changelog
  bool has(String version) =>
      _releases.containsKey(version.trim().toLowerCase());

  /// Adds a new release
  void add(Release release) {
    _releases[release.version.toString().toLowerCase()] = release;
  }

  /// Returns markdown text.
  /// - [keepEmptyUnreleased] preserves the "Unreleased" section even when it's empty
  @override
  String toString({bool keepEmptyUnreleased = false}) =>
      _Writer(keepEmptyUnreleased: keepEmptyUnreleased).write(this);
}

/// Writes changelog to markdown
class _Writer {
  _Writer({this.keepEmptyUnreleased = false});

  final bool keepEmptyUnreleased;

  String write(Changelog log) =>
      render(_changelog(log), flavor: flavors.changelog);

  Iterable<Node> _changelog(Changelog log) sync* {
    yield* log.header;
    if (log.unreleased.isNotEmpty || keepEmptyUnreleased) {
      yield* _unreleased(log.unreleased);
    }
    yield* log.history().toList().reversed.expand(_release);
  }

  Iterable<Node> _unreleased(Section section) sync* {
    yield Element('h2', _unreleasedHeader(section).toList());
    yield* _changes(section);
  }

  Iterable<Node> _unreleasedHeader(Section section) sync* {
    final text = Text('Unreleased');
    final link = section.link;
    if (link.isEmpty) {
      yield text;
    } else {
      yield _link(link, [text]);
    }
  }

  Iterable<Element> _release(Release section) sync* {
    yield Element('h2', _releaseHeader(section).toList());
    yield* _changes(section);
  }

  Iterable<Node> _releaseHeader(Release section) sync* {
    final dateSuffix = ' - ${section.date}';
    final link = section.link;
    if (link.isNotEmpty) {
      yield _link(link, [Text(section.version.toString())]);
      yield Text(dateSuffix);
    } else {
      yield Text(section.version.toString() + dateSuffix);
    }
  }

  Element _link(String link, List<Node> text) =>
      Element('a', text)..attributes['href'] = link;

  Iterable<Element> _changes(Section section) sync* {
    final types = Set.of(section.changes().map((e) => e.type)).toList();
    types.sort();
    for (final type in types) {
      final items = section.changes(type);
      if (items.isNotEmpty) {
        yield Element('h3', [Text(type)]);
        yield Element('ul',
            items.map((e) => Element('li', e.description.toList())).toList());
      }
    }
  }
}

/// Reads the changelog from markdown
class _Reader {
  const _Reader();

  Changelog read(String markdown) {
    final doc = Document();
    final log = Changelog();
    final sections = <List<Node>>[];
    for (final node in doc.parseLines(LineSplitter.split(markdown).toList())) {
      if (_isUnreleased(node) || _isRelease(node)) {
        sections.add([node]);
      } else if (sections.isEmpty) {
        log.header.add(node);
      } else {
        sections.last.add(node);
      }
    }
    for (final nodes in sections) {
      if (_isUnreleased(nodes.first)) {
        _changes(nodes.skip(1)).forEach(log.unreleased.add);
        log.unreleased.link =
            doc.linkReferences['unreleased']?.destination ?? '';
      } else {
        final release = _release(nodes);
        final version = release.version.toString().toLowerCase();
        release.link = doc.linkReferences[version]?.destination ?? '';
        log.add(release);
      }
    }
    return log;
  }

  static final _versionPrefix = RegExp(r'\d+\.\d+\.\d+');

  bool _isUnreleased(Node node) =>
      node is Element &&
      node.tag == 'h2' &&
      node.textContent.trim().toLowerCase() == 'unreleased';

  bool _isRelease(Node node) =>
      node is Element &&
      node.tag == 'h2' &&
      node.textContent.trim().startsWith(_versionPrefix);

  Release _release(Iterable<Node> nodes) {
    final header = nodes.first.textContent.trim();
    final parts = header.split(' - ');
    final release = Release(parts[0].trim(), parts[1].trim());
    _changes(nodes.skip(1)).forEach(release.add);
    return release;
  }

  List<Change> _changes(Iterable<Node> nodes) {
    final changes = <Change>[];
    var type = 'Changed';
    for (final node in nodes.whereType<Element>()) {
      if (node.tag == 'h3') {
        type = node.textContent.trim();
      } else if (node.tag == 'ul') {
        node.children!
            .whereType<Element>()
            .map((node) => Change(type, node.children!))
            .forEach(changes.add);
      }
    }
    return changes;
  }
}
