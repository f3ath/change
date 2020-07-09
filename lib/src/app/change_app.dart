import 'dart:io';

import 'package:change/model.dart';
import 'package:change/src/app/console.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart' as flafors;
import 'package:marker/marker.dart';

class ChangeApp {
  ChangeApp(this.file);

  final File file;

  Future<void> add(ChangeType type, String text) async {
    final changelog = await _read();

    changelog.unreleased.changes
        .add(type, MarkdownLine(Document().parseInline(text)));
    await _write(changelog);
  }

  Future<Release> get(String version) async {
    final changelog = await _read();
    return changelog.releases
        .firstWhere((element) => element.version == version);
  }

  Future<int> print(String version, Console console) async {
    final changelog = await _read();
    try {
      final release = changelog.releases
          .firstWhere((element) => element.version == version);
      final output = render(release.toMarkdown(), flavor: flafors.changelog);
      // Strip first line, which is already part of the command or commit message header
      console.log(output.substring(output.indexOf('\n') + 1));
      return 0;
    } on StateError {
      console.error("Version '${version}' not found!");
      return 1;
    }
  }

  Future<void> release(String version, String date, String diff) async {
    final changelog = await _read();
    changelog.release(version, date, link: diff.isNotEmpty ? diff : null);
    await _write(changelog);
  }

  Future<File> _write(Changelog changelog) =>
      file.writeAsString(changelog.dump());

  Future<Changelog> _read() async => Changelog.fromMarkdown(Document()
      .parseLines(await file.create().then((file) => file.readAsLines())));
}
