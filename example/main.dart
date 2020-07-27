import 'dart:io';

import 'package:change/change.dart';

/// This example shows how to parse a changelog.
/// Run it from the project root folder: `dart example/main.dart`
void main() async {
  final file = File('CHANGELOG.md');
  final changelog = Changelog.fromLines(await file.readAsLines());
  final releases = changelog.releases;
  final latest = releases.last;
  print('Changelog contains ${releases.length} releases');
  print('The latest is ${latest.version} released on ${latest.date}');
}
