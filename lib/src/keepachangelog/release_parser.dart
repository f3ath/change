part of 'package:change/src/keepachangelog/changelog_parser.dart';

class ReleaseParser extends ChangelogParser {
  ReleaseParser(Changelog changelog) : super(changelog);

  DateTime _date;
  String _diffUrl;
  String _version;

  void onText(String text) {
    final match = RegExp(r'^(.*) - (\d{4}-\d{2}-\d{2})$').firstMatch(text);
    if (match != null) {
      _date = DateTime.parse(match.group(2));
      if (match.group(1).isNotEmpty) _version = match.group(1);
    } else {
      // probably 'Unreleased'
      _version = text;
    }
  }

  void onEnter(Element el) {
    if (el.tag == 'a') {
      _diffUrl = el.attributes['href'];
    }
  }

  @override
  void onExit(Element el) {
    if (_path.length == 1) {
      _ch.releases.add(Release(_version, _date, diffUrl: _diffUrl));
    }
  }
}
