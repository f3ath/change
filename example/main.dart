import 'dart:io';

import 'package:change/model.dart';
import 'package:markdown/markdown.dart';

/// This example shows how to parse a changelog.
/// Run it from the project root folder: `dart example/main.dart`
void main() async {
  final file = File('CHANGELOG.md');
  final markdown = Document().parseLines(await file.readAsLines());
  final changelog = Changelog.fromMarkdown(markdown);
  final releases = changelog.releases;
  final latest = releases.last;
  print('Changelog contains ${releases.length} releases');
  print('The latest is ${latest.version} released on ${latest.date}');
}
