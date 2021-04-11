# change
Changelog manipulation in Dart. For the command-line tool, see [Cider](https://pub.dev/packages/cider).

## Features
- Supports some basic Markdown syntax, such as bold, italic, links, etc.
- CRUD operations on releases and changes.

## Limitations
- Works with changelogs following [keepachangelog](https://keepachangelog.com/en/1.0.0/) format only.
- [Semantic versioning](https://semver.org/) is implied.
- Dates must be in ISO 8601 (YYYY-MM-DD) format.
- Complex Markdown (e.g. tables, HTML, etc) will not work. For better markdown support consider opening a PR to [marker](https://github.com/f3ath/marker).

## Example
```dart
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
```