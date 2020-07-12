import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:change/app.dart';
import 'package:change/src/app/build_app.dart';
import 'package:test/test.dart';

void main() {
  Directory temp;
  MockConsole console;
  CommandRunner<int> app;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp();
    console = MockConsole();
    app = buildApp(console);
  });

  tearDown(() async {});

  test('Can add to empty', () async {
    final changelog = '${temp.path}/CHANGELOG.md';

    expect(
        await app
            .run(['added', 'Programmatically added change', '-p', changelog]),
        0);
    expect(File(changelog).readAsStringSync(),
        File('test/example/step0.md').readAsStringSync());
  });

  test('Can add changes', () async {
    final changelog = '${temp.path}/CHANGELOG.md';
    await File('test/example/step1.md').copy(changelog);

    expect(
        await app
            .run(['changed', 'Programmatically added change', '-p', changelog]),
        0);
    expect(
        await app.run([
          'deprecated',
          'Programmatically added deprecation',
          '-p',
          changelog
        ]),
        0);
    expect(File(changelog).readAsStringSync(),
        File('test/example/step2.md').readAsStringSync());
  });

  test('Can release', () async {
    final changelog = '${temp.path}/CHANGELOG.md';
    await File('test/example/step2.md').copy(changelog);

    expect(
        await app.run([
          'release',
          '-d',
          '2018-10-18',
          '1.1.0',
          '-l',
          'https://github.com/example/project/compare/%from%...%to%',
          '-p',
          changelog
        ]),
        0);
    expect(File(changelog).readAsStringSync(),
        File('test/example/step3.md').readAsStringSync());
  });

  test('Can print released versions', () async {
    final changelog = 'test/example/step3.md';

    expect(await app.run(['print', '-p', changelog]), 1,
        reason: 'Missing version');
    expect(console.errors.last, 'Please specify released version to print.');
    expect(await app.run(['print', '2.0.0', '-p', changelog]), 1,
        reason: 'Unknown version');
    expect(console.errors.last, 'Version \'2.0.0\' not found!');

    expect(await app.run(['print', '1.0.0', '-p', changelog]), 0);
    expect(console.logs.last, '''
### Added
- Initial version of the example''');
    expect(await app.run(['print', '1.1.0', '-p', changelog]), 0);
    expect(console.logs.last, '''
### Changed
- Change #1
- Change #2
- Programmatically added change

### Deprecated
- Programmatically added deprecation

[1.1.0]: https://github.com/example/project/compare/1.0.0...1.1.0''');
  });
}

class MockConsole implements Console {
  final errors = <String>[];
  final logs = <String>[];

  @override
  void error(Object message) {
    errors.add(message.toString());
  }

  @override
  void log(Object message) {
    logs.add(message.toString());
  }
}
