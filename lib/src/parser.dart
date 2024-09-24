import 'dart:convert';

import 'package:change/src/change.dart';
import 'package:change/src/changelog.dart';
import 'package:change/src/release.dart';
import 'package:change/src/section.dart';
import 'package:markdown/markdown.dart';
import 'package:pub_semver/pub_semver.dart';

/// Parses the [Changelog] from a markdown string.
/// Pass the [document] instance to have fine-grained control over markdown
/// parsing, such as extensions and html encoding.
Changelog parseChangelog(String markdown, {Document? document}) {
  final doc = document ?? Document(encodeHtml: false);
  final sections = <List<Node>>[];
  final log = Changelog();
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
      _parseInto(log.unreleased, nodes.skip(1));
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
  final regex = RegExp(r'(^.+)\s+-\s+(\d{4}-\d{2}-\d{2})(\s+\[YANKED\])?$',
      caseSensitive: false);
  final match = regex.firstMatch(header);
  if (match == null) {
    throw FormatException('Invalid release header format: "$header"');
  }
  final version = match.group(1)!.trim();
  final date = match.group(2)!.trim();
  final isYanked = match.group(3) != null;
  final release = Release(
    Version.parse(version),
    DateTime.parse(date),
    isYanked: isYanked,
  );
  _parseInto(release, nodes.skip(1));
  return release;
}

void _parseInto(Section section, Iterable<Node> nodes) {
  var type = 'Changed';
  var headerFinished = false;
  for (final node in nodes.whereType<Element>()) {
    if (node.tag == 'h3') {
      headerFinished = true;
      type = node.textContent.trim();
    } else if (!headerFinished) {
      section.preamble.add(node);
    } else if (node.tag == 'ul') {
      node.children!
          .whereType<Element>()
          .map((it) => Change(type, it.children!))
          .forEach(section.add);
    }
  }
}
