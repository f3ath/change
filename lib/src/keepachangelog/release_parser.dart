part of 'package:change/src/keepachangelog/changelog_parser.dart';


class ReleaseParser extends ChangelogParser {
  ReleaseParser(Changelog changelog) : super(changelog) {
    changelog.releases.add(Release());
  }

  void onText(String text) {
    final match = RegExp(r'^(.*) - (\d{4}-\d{2}-\d{2})$').firstMatch(text);
    if (match != null) {
      changelog.releases.last.date = match.group(2);
      if (match.group(1).isNotEmpty) {
        changelog.releases.last.version = match.group(1);
      }
    } else {
      // probably 'Unreleased'
      changelog.releases.last.version = text;
    }
  }

  void onEnter(Element el) {
    if (el.tag == 'a') {
      changelog.releases.last.diffUrl = el.attributes['href'];
    }
  }
}
