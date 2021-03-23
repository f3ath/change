import 'package:change/src/section.dart';
import 'package:pub_semver/pub_semver.dart';

class Release extends Section implements Comparable<Release> {
  Release(String version, this.date) : version = Version.parse(version);

  /// Release version
  final Version version;

  /// Release date
  final String date;

  /// Compares releases by date (oldest fist) and version (lower first)
  @override
  int compareTo(Release other) {
    final byDate = date.compareTo(other.date);
    if (byDate != 0) return byDate;
    return version.compareTo(other.version);
  }
}
