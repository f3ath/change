import 'dart:io';

import 'package:change/change.dart';
import 'package:markdown/markdown.dart';
import 'package:test/test.dart';

void main() {
  group('Parsing', () {
    group('Example', () {
      final file = File('test/md/keepachangelog.md');
      final changelog = Changelog.parse(file.readAsStringSync());

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
        expect(changelog.get('1.0.0').changes('Added').first.toString(),
            'New visual identity by @tylerfortune8.');
        expect(changelog.get('0.3.0').date, '2015-12-03');
        expect(changelog.get('0.3.0').link,
            'https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.0...v0.3.0');
        expect(changelog.get('0.0.8').link,
            'https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.7...v0.0.8');
        expect(changelog.get('0.0.8').changes().length, 4);
        expect(changelog.get('0.0.8').changes('Changed').length, 2);
        expect(changelog.get('0.0.8').changes('Fixed').length, 2);
        expect(
            changelog.get('0.0.8').changes('Changed').last.toString(),
            [
              'Reluctantly stop making fun of Brits only, since most of the world',
              'writes dates in a strange way.'
            ].join('\n'));
        expect(changelog.get('0.0.8').changes('Fixed').first.toString(),
            'Fix typos in recent README changes.');
      });
    });

    group('Non-standard', () {
      final file = File('test/md/non_standard.md');

      test('Can be read', () {
        final log = Changelog.parse(file.readAsStringSync());
        expect(log.unreleased, isNotEmpty);
        expect(log.history().single.link, isEmpty);
        expect(log.history().single.version.toString(), '0.0.1-beta+42');
        expect(log.history().single.changes().single.type, 'Invented');
        expect(log.unreleased.changes().single.type, 'Added');
      });
    });
  });

  group('Writing', () {
    group('Example', () {
      test('Example can be written unchanged', () {
        final file = File('test/md/keepachangelog.md');
        expect(
            Changelog.parse(file.readAsStringSync())
                .toString(keepEmptyUnreleased: true),
            file.readAsStringSync());
      });
    });

    test('Non-standard', () {
      final original = File('test/md/non_standard.md');
      final saved = File('test/md/non_standard_saved.md');
      expect(Changelog.parse(original.readAsStringSync()).toString(),
          saved.readAsStringSync());
    });

    final step1 = File('test/md/step1.md');
    final step2 = File('test/md/step2.md');
    final step3 = File('test/md/step3.md');

    test('Empty changelog is empty', () {
      expect(Changelog().toString(), isEmpty);
    });

    test('Can add entries', () {
      final changelog = Changelog.parse(step1.readAsStringSync());
      changelog.unreleased
          .add(Change('Changed', [Text('Programmatically added change')]));
      changelog.unreleased.add(
          Change('Deprecated', [Text('Programmatically added deprecation')]));
      expect(changelog.toString(), step2.readAsStringSync());
    });

    test('Can make release', () {
      final changelog = Changelog.parse(step2.readAsStringSync());
      final release = Release('1.1.0', '2018-10-18');
      release.addAll(changelog.unreleased.changes());
      final parent =
          changelog.history().lastWhere((r) => r.version < release.version);
      release.link =
          'https://github.com/example/project/compare/${parent.version}...${release.version}';
      changelog.add(release);
      changelog.unreleased.clear();
      expect(changelog.toString(), step3.readAsStringSync());
    });
  });
}
