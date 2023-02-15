import 'dart:io';

import 'package:change/change.dart';
import 'package:markdown/markdown.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  group('Parsing', () {
    group('Example', () {
      final file = File('test/md/keepachangelog.md');
      final changelog = parseChangelog(file.readAsStringSync());

      test('Unreleased', () {
        expect(changelog.unreleased, isEmpty);
        expect(changelog.unreleased.link,
            'https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...HEAD');
      });

      test('Check if version exists', () {
        expect(changelog.has('1.0.0'), isTrue);
        expect(changelog.has('5.5.5'), isFalse);
      });

      test('Iterate releases', () {
        expect(changelog.history().length, 12);
        expect(changelog.history().first.version.toString(), '0.0.1');
        expect(changelog.history().last.version.toString(), '1.0.0');
      });

      test('Read release properties', () {
        expect(() => changelog.get('5.5.5'), throwsStateError);
        expect(changelog.get('1.0.0').changes(type: 'Added').first.toString(),
            'New visual identity by @tylerfortune8.');
        expect(changelog.get('0.3.0').date, DateTime.parse('2015-12-03'));
        expect(changelog.get('0.3.0').link,
            'https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.0...v0.3.0');
        expect(changelog.get('0.0.8').link,
            'https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.7...v0.0.8');
        expect(changelog.get('0.0.8').changes().length, 4);
        expect(changelog.get('0.0.8').changes(type: 'Changed').length, 2);
        expect(changelog.get('0.0.8').changes(type: 'Fixed').length, 2);
        expect(
            changelog.get('0.0.8').changes(type: 'Changed').last.toString(),
            [
              'Reluctantly stop making fun of Brits only, since most of the world',
              'writes dates in a strange way.'
            ].join('\n'));
        expect(changelog.get('0.0.8').changes(type: 'Fixed').first.toString(),
            'Fix typos in recent README changes.');
      });

      test('Yanked releases', () {
        final file = File('test/md/yanked.md');
        final changelog = parseChangelog(file.readAsStringSync());

        expect(changelog.get('0.1.0').isYanked, isFalse);
        expect(changelog.get('0.2.0').isYanked, isTrue);
        expect(changelog.get('0.3.0').isYanked, isTrue);
        expect(changelog.get('0.4.0').isYanked, isTrue);
        expect(changelog.get('0.5.0').isYanked, isTrue);
      });
    });

    group('Non-standard', () {
      final file = File('test/md/non_standard.md');

      test('Can be read', () {
        final log = parseChangelog(file.readAsStringSync());
        expect(log.unreleased, isNotEmpty);
        expect(log.history().single.link, isEmpty);
        expect(log.history().single.version.toString(), '0.0.1-beta+42');
        expect(log.history().single.changes().single.type, 'Invented');
        expect(log.unreleased.changes().single.type, 'Added');
      });
    });
  });

  group('Printing', () {
    group('Example', () {
      test('Example can be written unchanged', () {
        final file = File('test/md/keepachangelog.md');
        final log = parseChangelog(file.readAsStringSync());
        final markdown = printChangelog(log, keepEmptyUnreleased: true);
        expect(markdown, file.readAsStringSync());
      });
    });

    test('Non-standard', () {
      final original = File('test/md/non_standard.md');
      final saved = File('test/md/non_standard_saved.md');
      expect(printChangelog(parseChangelog(original.readAsStringSync())),
          saved.readAsStringSync());
    });

    final step1 = File('test/md/step1.md');
    final step2 = File('test/md/step2.md');
    final step3 = File('test/md/step3.md');
    final step4 = File('test/md/step4.md');

    test('Empty changelog is empty', () {
      expect(printChangelog(Changelog()), isEmpty);
    });

    test('Can add entries', () {
      final changelog = parseChangelog(step1.readAsStringSync());
      changelog.unreleased
          .add(Change('Changed', [Text('Programmatically added change')]));
      changelog.unreleased.add(
          Change('Deprecated', [Text('Programmatically added deprecation')]));
      expect(printChangelog(changelog), step2.readAsStringSync());
    });

    test('Can make release', () {
      final changelog = parseChangelog(step2.readAsStringSync());
      final release =
          Release(Version.parse('1.1.0'), DateTime.parse('2018-10-18'));
      release.addAll(changelog.unreleased.changes());
      final parent = changelog.preceding(release.version)!;
      release.link =
          'https://github.com/example/project/compare/${parent.version}...${release.version}';
      changelog.add(release);
      changelog.unreleased.clear();
      expect(printChangelog(changelog), step3.readAsStringSync());
    });

    test('Can yank release', () {
      final changelog = parseChangelog(step3.readAsStringSync());
      changelog.get('1.1.0').isYanked = true;
      expect(printChangelog(changelog), step4.readAsStringSync());
    });

    test('Can not add an existing release', () {
      final changelog = parseChangelog(step1.readAsStringSync());
      final release =
          Release(Version.parse('1.0.0'), DateTime.parse('2018-10-18'));
      release.add(Change('Added', [Text('Something')]));
      expect(() => changelog.add(release), throwsStateError);
    });

    test('Can print unreleased', () {
      final log = Changelog();
      log.unreleased.add(Change('Added', [Text('Some change')]));
      log.unreleased.link = 'https://example.com';
      expect(
          printUnreleased(log.unreleased),
          [
            '## [Unreleased]',
            '### Added',
            '- Some change',
            '',
            '[Unreleased]: https://example.com',
          ].join('\n'));
    });

    test('Can print release', () {
      final release =
          Release(Version.parse('0.0.1'), DateTime.parse('2020-02-02'));
      release.add(Change('Added', [Text('Some change')]));
      release.link = 'https://example.com';
      expect(
          printRelease(release),
          [
            '## [0.0.1] - 2020-02-02',
            '### Added',
            '- Some change',
            '',
            '[0.0.1]: https://example.com',
          ].join('\n'));
    });
  });
}
