import 'dart:io';

import 'package:change/model.dart';
import 'package:test/test.dart';

void main() {
  final example = File('test/keepachangelog.md');
  final text = example.readAsLinesSync();

  group('Parsing', () {
    test('Can read the example', () async {
      final changelog = Changelog.fromLines(text);
      expect(changelog.header, isNotEmpty);

      expect(changelog.unreleased.changes.get(ChangeType.change).length, 1);
      expect(changelog.unreleased.link,
          'https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...HEAD');
      expect(changelog.unreleased.changes.get(ChangeType.change).first.text,
          startsWith('Update and improvement'));
      expect(changelog.unreleased.changes.get(ChangeType.change).length, 1);
      expect(changelog.unreleased.changes.get(ChangeType.addition).length, 0);

      expect(changelog.releases.length, 12);
      final v_0_0_1 = changelog.releases.firstWhere(
          (release) => release.version == '0.0.1',
          orElse: () => throw 'Oops');
      expect(v_0_0_1.link, isEmpty);
      expect(v_0_0_1.changes.get(ChangeType.addition).length, 5);
      final v_0_0_2 = changelog.releases.firstWhere(
          (release) => release.version == '0.0.2',
          orElse: () => throw 'Oops');
      expect(v_0_0_2.link,
          'https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2');
      expect(v_0_0_2.changes.get(ChangeType.addition).length, 1);
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
      changelog.unreleased.changes
          .addText(ChangeType.change, 'Programmatically added change');
      changelog.unreleased.changes.addText(
          ChangeType.deprecation, 'Programmatically added deprecation');
      expect(changelog.dump(), step2.readAsStringSync());
    });

    test('Can add entries', () {
      final changelog = Changelog.fromLines(step1.readAsLinesSync());
      changelog.unreleased.changes
          .addText(ChangeType.change, 'Programmatically added change');
      changelog.unreleased.changes.addText(
          ChangeType.deprecation, 'Programmatically added deprecation');
      expect(changelog.dump(), step2.readAsStringSync());
    });

    test('Can make release', () {
      final changelog = Changelog.fromLines(step2.readAsLinesSync());
      changelog.release('1.1.0', '2018-10-18',
          link: 'https://github.com/example/project/compare/%from%...%to%');
      expect(changelog.dump(), step3.readAsStringSync());
    });

    test('Release supports multiple major versions', () {
      final changelog = Changelog();
      changelog.releases.add(Release('1.0.0', '2020-06-01'));
      changelog.releases.add(Release('2.0.0', '2020-06-02'));
      changelog.unreleased.changes
          .addText(ChangeType.addition, 'My new feature');
      changelog.release('1.1.0', '2020-06-03',
          link: 'https://github.com/example/project/compare/%from%...%to%');
      expect(changelog.releases.last.version, '1.1.0');
      expect(changelog.releases.last.link,
          'https://github.com/example/project/compare/1.0.0...1.1.0');
    });
  });
}
