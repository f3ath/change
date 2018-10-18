import 'dart:io';

import 'package:change/change.dart';
import 'package:test/test.dart';

void main() {
  final file = File('test/example/changelog.md');
  group('Parsing', () {
    test('Can parse example', () async {
      final cl = await Changelog.fromFile(file);
      expect(cl.title, 'Changelog');
      expect(cl.manifest.toString(), startsWith('All notable changes'));
      expect(
          cl.manifest.toString(),
          endsWith(
              'to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).'));
      expect(cl.releases.first.version, 'Unreleased');
      expect(cl.releases.first.link,
          'https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...HEAD');
      expect(cl.releases.first.blocks.first.type, 'Changed');
      expect(cl.releases.first.blocks.first.changes.first,
          startsWith('Update and improvement'));

      expect(cl.releases.first.blocks.first.changes.first,
          endsWith('from [@m-aciek](https://github.com/m-aciek).'));

      expect(cl.releases.last.version, '0.0.1');
      expect(cl.releases.last.date, '2014-05-31');
      expect(cl.releases.last.blocks.last.changes.last,
          'Counter-examples: "What makes unicorns cry?"');

      expect(cl.releases[1].version, '1.0.0');
      expect(cl.releases[1].date, '2017-06-20');
    });
  });

  group('toMarkdown()', () {
    test('does not change the source file', () async {
      final buf = StringBuffer();
      final cl = await Changelog.fromFile(file);
      cl.writeMarkdown(buf);
      expect(buf.toString().trim(), file.readAsStringSync());
    });
    test('empty', () {
      final buf = StringBuffer();
      Changelog().writeMarkdown(buf);
      expect(buf.toString().trim(), '');
    });
    test('just title', () {
      final buf = StringBuffer();
      final c = Changelog()
        ..title = 'My changelog';
      c.writeMarkdown(buf);
      expect(buf.toString().trim(), '# My changelog');
    });
  });

  group('Manipulation', () {
    test('Can add unreleased', () {

    });
  });
}
