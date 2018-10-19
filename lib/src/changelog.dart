import 'dart:async';
import 'dart:io';

import 'package:change/keepachangelog.dart' as keep;

typedef Changelog Parser(List<String> lines);
typedef StringBuffer Printer(Changelog changelog, {StringBuffer buffer});

/// A changelog
class Changelog {
  /// The [title]. Usually 'Changelog'.
  String title = '';

  /// true if [Changelog] has a non empty title.
  bool get hasTitle => title != null && title.isNotEmpty;

  /// A few paragraphs of text which comes right after the [title].
  final manifest = List<String>();

  /// Releases in no particular order including the Unreleased section.
  final releases = List<Release>();

  /// true if the [Changelog] contains no changes.
  bool get isEmpty => releases.every((r) => r.isEmpty);

  /// Parses an .md [file] and returns a [Changelog] object.
  static Future<Changelog> readFile(String file,
          {Parser parser = keep.parser}) async =>
      parser(await File(file).readAsLines());

  String toMarkdown({Printer printer = keep.printer, StringBuffer buffer}) =>
      printer(this, buffer: buffer).toString().trim();

  /// Saves the content to the [file].
  Future<File> writeFile(String file, {Printer printer}) =>
      File(file).writeAsString(this.toString());
}

/// A release.
class Release {
  /// Release [version] or 'Unreleased'
  String version;

  /// [date] format is supposed to be YYYY-MM-DD
  String date;

  /// The [diffUrl] is a link to the diff with the previous release, if any.
  String diffUrl;

  /// Changes in this release grouped in blocks by type
  final List<Block> blocks = [];

  /// true is the [Release] has a non-empty link.
  get hasLink => diffUrl != null && diffUrl.isNotEmpty;

  /// true if the [Release] contains no changes
  get isEmpty => blocks.every((b) => b.isEmpty);

  addChange(String type, String description) {}
}

/// A set of changes of the same type.
class Block {
  /// The type of the changes: Added, Changed, Deprecated, etc
  String type;

  /// The list of [changes] of the given [type].
  final changes = List<String>();

  /// true if the [Block] contains no changes
  get isEmpty => changes.every((c) => c.isEmpty);
}
