import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:change/model.dart';
import 'package:change/src/app/change_app.dart';
import 'package:change/src/app/console.dart';
import 'package:intl/intl.dart';

CommandRunner<int> buildApp(Console console) {
  return CommandRunner<int>('change', 'Changelog manager.')
    ..addCommand(_Add(console, ChangeType.addition, 'added'))
    ..addCommand(_Add(console, ChangeType.change, 'changed'))
    ..addCommand(_Add(console, ChangeType.deprecation, 'deprecated'))
    ..addCommand(_Add(console, ChangeType.removal, 'removed'))
    ..addCommand(_Add(console, ChangeType.fix, 'fixed'))
    ..addCommand(_Add(console, ChangeType.security, 'security'))
    ..addCommand(_Release(console))
    ..argParser.addOption('changelog-path',
        abbr: 'p',
        help: 'Full path to CHANGELOG.md',
        defaultsTo: 'CHANGELOG.md')
    ..argParser.addOption('link',
        abbr: 'l',
        help:
            'Diff link template. Use %from% and %to% as version placeholders.')
    ..argParser.addOption('date',
        abbr: 'd',
        help: 'Release date. Today, if not specified',
        defaultsTo: DateFormat('y-MM-dd').format(DateTime.now()));
}

class _Add extends _ChangeCommand {
  _Add(this.console, this.type, this.name);

  final ChangeType type;
  final Console console;
  @override
  final String name;

  @override
  String get description =>
      'Adds a new change to Unreleased ${type.name} section';

  @override
  Future<int> run() async {
    if (globalResults.arguments.length < 2) {
      console.error('Too few arguments');
      return 1;
    }
    await _app().add(type, globalResults.arguments[1]);
    return 0;
  }
}

class _Release extends _ChangeCommand {
  _Release(this.console);

  final Console console;

  @override
  String get description => 'Creates a new release section from Unreleased';

  @override
  String get name => 'release';

  @override
  Future<int> run() async {
    if (globalResults.arguments.isEmpty) {
      console.error('Please specify release version.');
      return 1;
    }
    await _app().release(globalResults.arguments[1], globalResults['date'],
        globalResults['link']);
    return 0;
  }
}

abstract class _ChangeCommand extends Command<int> {
  ChangeApp _app() => ChangeApp(File(globalResults['changelog-path']));
}
