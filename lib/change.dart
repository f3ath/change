import 'dart:async';
import 'dart:io';

import 'package:change/src/parser.dart';

/// A changelog
class Changelog {
  /// The [title]. Usually 'Changelog'.
  String title;

  /// A few paragraphs of text which comes right after the [title].
  final Manifest manifest;

  /// Releases in no particular order including the Unreleased section.
  final List<Release> releases = [];

  Changelog({String this.title = '', List<String> manifest})
      : manifest = Manifest(manifest ?? []);

  /// Parses an .md file and returns a [Changelog] object.
  static Future<Changelog> fromFile(File file) async =>
      parseLines(await file.readAsLines());

  /// Writes markdown formatted changelog to the [buffer]
  void writeMarkdown(StringBuffer buffer) {
    if (title.isNotEmpty) buffer.writeln('# $title');
    manifest.writeMarkdown(buffer);
    releases.forEach((r) => r.writeMarkdown(buffer));
    releases
        .where((r) => r.hasLink)
        .forEach((r) => buffer.writeln('[${r.version}]: ${r.link}'));
  }
}

/// A set of paragraphs.
class Manifest {
  final List<String> paragraphs;

  Manifest([List<String> paragraphs]) : paragraphs = paragraphs ?? [];

  /// Writes markdown to [buffer].
  writeMarkdown(StringBuffer buffer) {
    paragraphs.forEach((p) {
      buffer.writeln(p);
      buffer.writeln();
    });
  }

  @override
  String toString() {
    final buf = StringBuffer();
    writeMarkdown(buf);
    return buf.toString().trim();
  }
}

/// A release.
class Release {
  /// Release [version] or 'Unreleased'
  String version;

  /// [date] format is supposed to be YYYY-MM-DD
  String date;

  /// The [link] to the diff with the previous release, if any.
  String link;

  /// Changes in this release grouped in blocks by type
  final List<Block> blocks = [];

  get hasLink => link != null && link.isNotEmpty;

  /// Writes markdown to [buffer].
  void writeMarkdown(StringBuffer buffer) {
    if (link != null && link.isNotEmpty) {
      buffer.write('## [$version]');
    } else {
      buffer.write('## $version');
    }
    if (date != null && date.isNotEmpty) buffer.write(' - ${date}');
    buffer.writeln();
    blocks.forEach((b) => b.writeMarkdown(buffer));
  }
}

/// A set of changes of the same type.
class Block {
  /// The type of the changes: Added, Changed, Deprecated, etc
  String type;

  /// The list of [changes] of the given [type].
  final List<String> changes = [];

  /// Writes markdown to [buffer].
  void writeMarkdown(StringBuffer buffer) {
    buffer.writeln('### $type');
    changes.forEach((c) => buffer.writeln('- $c'));
    buffer.writeln();
  }
}
