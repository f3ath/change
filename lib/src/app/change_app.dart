import 'dart:io';

import 'package:change/model.dart';
import 'package:markdown/markdown.dart';

class ChangeApp {
  ChangeApp(this.file);

  final File file;

  Future<void> add(ChangeType type, String text) async {
    final changelog = await _read();

    changelog.unreleased.add(type, MarkdownLine(Document().parseInline(text)));
    await _write(changelog);
  }

  Future<void> release(String version, String date, String diff) async {
    final changelog = await _read();
    changelog.release(version, date, diff: diff.isNotEmpty ? diff : null);
    await _write(changelog);
  }

  Future<File> _write(Changelog changelog) =>
      file.writeAsString(changelog.dump());

  Future<Changelog> _read() async =>
      Changelog.fromMarkdown(Document().parseLines(await file.readAsLines()));
}
