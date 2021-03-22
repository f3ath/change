import 'dart:io';

import 'package:change/change.dart';
import 'package:markdown/markdown.dart';
import 'package:test/test.dart';

void main() {
  group('Parsing', () {
    test('Can read the example', () async {
      final file = File('test/keepachangelog.md');
      final changelog = Changelog.fromMarkdown(file.readAsLinesSync());
      expect(changelog.header, isNotEmpty);

      expect(changelog.unreleased.changes.length, 1);
      expect(changelog.unreleased.changes['Changed']!.length, 1);
      expect(changelog.unreleased.diff,
          'https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...HEAD');
      expect(changelog.unreleased.changes['Changed']!.single.toString(),
          startsWith('Update and improvement'));

      expect(changelog.releases.length, 12);
      final v_0_0_1 =
          changelog.releases.firstWhere((r) => r.version.toString() == '0.0.1');
      expect(v_0_0_1.diff, isNull);
      expect(v_0_0_1.changes['Added']!.length, 5);
      final v_0_0_2 =
          changelog.releases.firstWhere((r) => r.version.toString() == '0.0.2');
      expect(v_0_0_2.diff,
          'https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2');
      expect(v_0_0_2.changes['Added']!.length, 1);
    });
  });

  group('Rendering', () {
    test('Can read the example and render it unchanged', () {
      final file = File('test/keepachangelog.md');
      final changelog = Changelog.fromMarkdown(file.readAsLinesSync());
      expect(changelog.toText(), file.readAsStringSync());
    });
  });

  group('Manipulation', () {
    final step1 = File('test/example/step1.md');
    final step2 = File('test/example/step2.md');
    final step3 = File('test/example/step3.md');
    final template = 'https://github.com/example/project/compare/%from%...%to%';

    test('Can add entries', () {
      final changelog = Changelog.fromMarkdown(step1.readAsLinesSync());
      changelog.unreleased
          .add('Changed', Change([Text('Programmatically added change')]));
      changelog.unreleased.add('Deprecated',
          Change([Text('Programmatically added deprecation')]));
      expect(changelog.toText(), step2.readAsStringSync());
    });

    test('Can make release', () {
      final changelog = Changelog.fromMarkdown(step2.readAsLinesSync());
      changelog.release('1.1.0', '2018-10-18',
          linkTemplate:
              'https://github.com/example/project/compare/%from%...%to%');
      expect(changelog.toText(), step3.readAsStringSync());
    });

    test('Can make initial release', () {
      final changelog = Changelog.fromMarkdown(
          File('test/example/only-unreleased.md').readAsLinesSync());
      changelog.release('1.0.0', '2018-10-18', linkTemplate: template);
      expect(changelog.toText(),
          File('test/example/initial-release.md').readAsStringSync().trim());
    });

    test('Release supports multiple major versions', () {
      final changelog = Changelog();
      changelog.add(Release('1.0.0', '2020-06-01'));
      changelog.add(Release('2.0.0', '2020-06-02'));
      changelog.unreleased.changes
          .add(Change('Added', [Text('My new feature')]));
      changelog.release('1.1.0', '2020-06-03', linkTemplate: template);
      expect(changelog.releases.last.version.toString(), '2.0.0');
      expect(changelog.get('1.1.0').diff,
          'https://github.com/example/project/compare/1.0.0...1.1.0');
    });

    test('Can change header', () {
      final changelog = Changelog();

      changelog.header.addAll([
        Element('h1', [Text('My changelog')])
      ]);
      expect(
          changelog.toText(),
          '# My changelog\n'
          '## Unreleased');
    });
  });
}
