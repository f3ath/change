import 'dart:io';

import 'package:change/changelog.dart';
import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:test/test.dart';

void main() {
  final example = File('test/keepachangelog.md');
  final text = example.readAsLinesSync();
  final template = 'https://github.com/example/project/compare/%from%...%to%';

  group('Parsing', () {
    test('Can read the example', () async {
      final changelog = Changelog.fromLines(text);
      expect(changelog.header, isNotEmpty);

      expect(changelog.unreleased.changed.length, 1);
      expect(changelog.unreleased.link.orThrow(() => 'Link must be set'),
          'https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...HEAD');
      expect(changelog.unreleased.changed.first.toString(),
          startsWith('Update and improvement'));
      expect(changelog.unreleased.changed.length, 1);
      expect(changelog.unreleased.added.length, 0);

      expect(changelog.releases.length, 12);
      final v_0_0_1 = changelog.releases.firstWhere(
          (release) => release.version == '0.0.1',
          orElse: () => throw 'Oops');
      expect(v_0_0_1.link, isA<Nothing>());
      expect(v_0_0_1.added.length, 5);
      final v_0_0_2 = changelog.releases.firstWhere(
          (release) => release.version == '0.0.2',
          orElse: () => throw 'Oops');
      expect(v_0_0_2.link.orThrow(() => 'Link must be set'),
          'https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2');
      expect(v_0_0_2.added.length, 1);
    });

    test('Can read incomplete changelog', () {
      final changelog = Changelog.fromLines(
          File('test/example/incomplete.md').readAsLinesSync());
      expect(changelog.unreleased.changed.single.toString(),
          'Change without type');
      expect(changelog.dump(),
          File('test/example/incomplete-saved.md').readAsStringSync().trim());
    });
  });

  group('Rendering', () {
    test('Can read the example and render it unchanged', () {
      final changelog = Changelog.fromLines(text);
      expect(changelog.dump(), example.readAsStringSync());
    });
  });

  group('Manipulation', () {
    final step1 = File('test/example/step1.md');
    final step2 = File('test/example/step2.md');
    final step3 = File('test/example/step3.md');

    test('Can add entries', () {
      final changelog = Changelog.fromLines(step1.readAsLinesSync());
      changelog.unreleased.changed.add('Programmatically added change');
      changelog.unreleased.deprecated.add('Programmatically added deprecation');
      expect(changelog.dump(), step2.readAsStringSync());
    });

    test('Can add entries', () {
      final changelog = Changelog.fromLines(step1.readAsLinesSync());
      changelog.unreleased.changed.add('Programmatically added change');
      changelog.unreleased.deprecated.add('Programmatically added deprecation');
      expect(changelog.dump(), step2.readAsStringSync());
    });

    test('Can make release', () {
      final changelog = Changelog.fromLines(step2.readAsLinesSync());
      changelog.release('1.1.0', '2018-10-18',
          link: 'https://github.com/example/project/compare/%from%...%to%');
      expect(changelog.dump(), step3.readAsStringSync());
    });

    test('Can make initial release', () {
      final changelog = Changelog.fromLines(
          File('test/example/only-unreleased.md').readAsLinesSync());
      changelog.release('1.0.0', '2018-10-18', link: template);
      expect(changelog.dump(),
          File('test/example/initial-release.md').readAsStringSync().trim());
    });

    test('Release supports multiple major versions', () {
      final changelog = Changelog();
      changelog.releases.add(Release('1.0.0', date: '2020-06-01'));
      changelog.releases.add(Release('2.0.0', date: '2020-06-02'));
      changelog.unreleased.added.add('My new feature');
      changelog.release('1.1.0', '2020-06-03', link: template);
      expect(changelog.releases.last.version, '1.1.0');
      expect(changelog.releases.last.link.orThrow(() => 'Link must be set'),
          'https://github.com/example/project/compare/1.0.0...1.1.0');
    });

    test('Header can not contain h2 or h3', () {
      final changelog = Changelog();
      expect(
          () => changelog.setHeader([
                Element('h2', [Text('Release header')])
              ]),
          throwsFormatException);
      expect(
          () => changelog.setHeader([
                Element('h3', [Text('Type header')])
              ]),
          throwsFormatException);
    });

    test('Can change header', () {
      final changelog = Changelog();

      changelog.setHeader([
        Element('h1', [Text('My changelog')])
      ]);
      expect(
          changelog.dump(),
          '# My changelog\n'
          '## Unreleased');
    });
  });
}
