import 'package:change/src/section.dart';
import 'package:pub_semver/pub_semver.dart';

class Release extends Section implements Comparable<Release> {
  Release(this.version, this.date, {this.isYanked = false});

  /// Release version.
  Version version;

  /// Release date.
  DateTime date;

  /// True for yanked releases.
  bool isYanked;

  /// Compares releases by date (oldest first) and version (lower first).
  @override
  int compareTo(Release other) {
    final byDate = date.compareTo(other.date);
    if (byDate != 0) return byDate;
    return version.compareTo(other.version);
  }
}
