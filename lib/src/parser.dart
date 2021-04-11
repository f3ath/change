import 'dart:convert';

import 'package:change/src/change.dart';
import 'package:change/src/changelog.dart';
import 'package:change/src/release.dart';
import 'package:markdown/markdown.dart';
import 'package:pub_semver/pub_semver.dart';

/// Parses the [Changelog] from a markdown string
Changelog parseChangelog(String markdown) {
  final log = Changelog();
  final doc = Document();
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
      log.unreleased.link = doc.linkReferences['unreleased']?.destination ?? '';
    } else {
      final release = _release(nodes);
      final version = release.version.toString().toLowerCase();
      release.link = doc.linkReferences[version]?.destination ?? '';
      log.add(release);
    }
  }
  return log;
}

final _versionPrefix = RegExp(r'\d+\.\d+\.\d+');

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
  final version = Version.parse(parts[0].trim());
  final parse = DateTime.parse(parts[1].trim());
  final release = Release(version, parse);
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
