import 'dart:io';

import 'package:change/model.dart';
import 'package:markdown/markdown.dart';
import 'package:test/test.dart';

void main() {
  final example = File('test/keepachangelog.md');
  final nodes = Document().parseLines(example.readAsLinesSync());

  group('Parsing', () {
    test('Can read the example', () async {
      final changelog = Changelog.fromMarkdown(nodes);
      expect(changelog.header, isNotEmpty);

      expect(changelog.unreleased.get(ChangeType.change).length, 1);
      expect(changelog.unreleased.link,
          'https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...HEAD');
      expect(changelog.unreleased.get(ChangeType.change).first.text,
          startsWith('Update and improvement'));
      expect(changelog.unreleased.get(ChangeType.change).length, 1);
      expect(changelog.unreleased.get(ChangeType.addition).length, 0);

      expect(changelog.releases.length, 12);
      final v_0_0_1 = changelog.releases.firstWhere(
          (release) => release.version == '0.0.1',
          orElse: () => throw 'Oops');
      expect(v_0_0_1.link, isEmpty);
      expect(v_0_0_1.get(ChangeType.addition).length, 5);
      final v_0_0_2 = changelog.releases.firstWhere(
          (release) => release.version == '0.0.2',
          orElse: () => throw 'Oops');
      expect(v_0_0_2.link,
          'https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2');
      expect(v_0_0_2.get(ChangeType.addition).length, 1);
    });
  });

  group('Rendering', () {
    test('Can read the example and render it unchanged', () {
      final changelog = Changelog.fromMarkdown(nodes);
      expect(changelog.dump(), example.readAsStringSync());
    });
  });

  group('Manipulation', () {
    final step1 = File('test/example/step1.md');
    final step2 = File('test/example/step2.md');
    final step3 = File('test/example/step3.md');

    test('Can add entries', () {
      final nodes = Document().parseLines(step1.readAsLinesSync());
      final changelog = Changelog.fromMarkdown(nodes);
      changelog.unreleased.add(ChangeType.change,
          MarkdownLine([Text('Programmatically added change')]));
      changelog.unreleased.add(ChangeType.deprecation,
          MarkdownLine([Text('Programmatically added deprecation')]));
      expect(changelog.dump(), step2.readAsStringSync());
    });

    test('Can add entries', () {
      final nodes = Document().parseLines(step1.readAsLinesSync());
      final changelog = Changelog.fromMarkdown(nodes);
      changelog.unreleased.add(ChangeType.change,
          MarkdownLine([Text('Programmatically added change')]));
      changelog.unreleased.add(ChangeType.deprecation,
          MarkdownLine([Text('Programmatically added deprecation')]));
      expect(changelog.dump(), step2.readAsStringSync());
    });

    test('Can make release', () {
      final nodes = Document().parseLines(step2.readAsLinesSync());
      final changelog = Changelog.fromMarkdown(nodes);
      final newVersion = '1.1.0';
      final lastVersion = changelog.releases.last.version;
      final newRelease = Release(newVersion, '2018-10-18');
      final repo = Github('example', 'project');
      newRelease.copyChangesFrom(changelog.unreleased);
      newRelease.link = repo.diffLink(lastVersion, newVersion);
      changelog.releases.add(newRelease);
      changelog.unreleased.clearChanges();
      changelog.unreleased.link = repo.diffLink(newVersion, 'HEAD');
      expect(changelog.dump(), step3.readAsStringSync());
    });
  });
}

abstract class Repo {
  /// Generates the diff link between [before] and [after] versions.
  String diffLink(String before, String after);
}

class Github implements Repo {
  Github(this.user, this.repo);

  final String user;
  final String repo;

  @override
  String diffLink(String before, String after) =>
      'https://github.com/$user/$repo/compare/$before...$after';
}
