import 'package:change/src/anchor.dart';
import 'package:change/src/section.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart';
import 'package:pub_semver/pub_semver.dart';

/// A release section
class Release extends Section implements Comparable<Release> {
  Release(String version, String date)
      : version = Version.parse(version),
        date = DateTime.parse(date);

  static final dateFormat = DateFormat('yyyy-MM-dd');

  /// Release version
  Version version;

  /// Release date
  DateTime date;


  /// Diff link
  String? diff;

  @override
  Iterable<Node> toMarkdown() {
    final header = <Node>[];
    final diff = this.diff;
    final dateSuffix = ' - ${dateFormat.format(date)}';
    if (diff != null) {
      header.add(Anchor(diff, [Text(version.toString())]));
      header.add(Text(dateSuffix));
    } else {
      header.add(Text(version.toString() + dateSuffix));
    }
    return <Node>[Element('h2', header)].followedBy(super.toMarkdown());
  }

  @override
  int compareTo(Release other) {
    final byDate = date.compareTo(other.date);
    if (byDate != 0) return byDate;
    return version.compareTo(other.version);
  }
}
