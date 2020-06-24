import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:change/app.dart';
import 'package:change/src/app/build_app.dart';
import 'package:test/test.dart';

void main() {
  Directory temp;
  Console console;
  CommandRunner<int> app;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp();
    console = MockConsole();
    app = buildApp(console);
  });

  tearDown(() async {});

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
          '1.1.0',
          '-d',
          '2018-10-18',
          '-l',
          'https://github.com/example/project/compare/%from%...%to%',
          '-p',
          changelog
        ]),
        0);
    expect(File(changelog).readAsStringSync(),
        File('test/example/step3.md').readAsStringSync());
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
