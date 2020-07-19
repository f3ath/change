import 'package:args/command_runner.dart';
import 'package:change/src/app/command/add.dart';
import 'package:change/src/app/command/print.dart';
import 'package:change/src/app/command/release.dart';
import 'package:change/src/app/console.dart';
import 'package:change/src/model/change_type.dart';
import 'package:intl/intl.dart';

CommandRunner<int> buildApp(Console console) => CommandRunner<int>(
    'change', 'Changelog manager.')
  ..addCommand(Add(console, ChangeType.addition, 'added'))
  ..addCommand(Add(console, ChangeType.change, 'changed'))
  ..addCommand(Add(console, ChangeType.deprecation, 'deprecated'))
  ..addCommand(Add(console, ChangeType.removal, 'removed'))
  ..addCommand(Add(console, ChangeType.fix, 'fixed'))
  ..addCommand(Add(console, ChangeType.security, 'security'))
  ..addCommand(Print(console))
  ..addCommand(Release(console))
  ..argParser.addOption('changelog-path',
      abbr: 'p', help: 'Full path to CHANGELOG.md', defaultsTo: 'CHANGELOG.md')
  ..argParser.addOption('link',
      abbr: 'l',
      help: 'Diff link template. Use %from% and %to% as version placeholders.',
      defaultsTo: '')
  ..argParser.addOption('date',
      abbr: 'd',
      help: 'Release date. Today, if not specified',
      defaultsTo: DateFormat('y-MM-dd').format(DateTime.now()));
