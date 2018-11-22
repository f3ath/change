import 'dart:io';

import 'package:change/changelog.dart';
import 'package:test/test.dart';

void main() {
  group('Parsing', () {
    test('Can load example and write it back unchanged', () async {
      final file = File('test/keepachangelog.md');
      final changelog = await Changelog.fromFile(file);
      final markdown = changelog.toMarkdown();

      expect(markdown, equals(file.readAsStringSync()));
    });
  });

  group('Manipulation', () {
    final step01 = File('test/example/step01.md');
    final step02 = File('test/example/step02.md');

    test('Can add an unreleased change', () async {
      final cl = await Changelog.fromFile(step01);
      cl.change('Programmatically added change');
      cl.deprecate('Programmatically added deprecation');
      expect(cl.toMarkdown(), equals(step02.readAsStringSync()));
    });
  });
}
