import 'package:change/change.dart';
import 'package:markdown/markdown.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('Browser compatibility smoke test', () {
    final c = Changelog();
    final release =
        Release(Version.parse('1.0.0'), DateTime.parse('2022-02-22'))
          ..add(Change('Added', [Text('Some change')]))
          ..link = 'https://example.com';
    c.add(release);

    final expected = '## [1.0.0] - 2022-02-22\n'
        '### Added\n'
        '- Some change\n'
        '\n'
        '[1.0.0]: https://example.com';

    expect(printChangelog(c), equals(expected));
  }, testOn: 'browser');
}
