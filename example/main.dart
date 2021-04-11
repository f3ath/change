import 'dart:io';

import 'package:change/change.dart';

/// This example shows how to parse a changelog.
/// Run it from the project root folder: `dart example/main.dart`
void main() {
  final file = File('CHANGELOG.md');
  final log = parseChangelog(file.readAsStringSync());
  final latest = log.history().last;
  print('Changelog contains ${log.history().length} releases.');
  print('The latest version is ${latest.version}');
  print('released on ${latest.date}');
  print('and containing ${latest.changes().length} change(s).');
}
