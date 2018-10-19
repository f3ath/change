part of 'package:change/src/keepachangelog/changelog_parser.dart';

class TitleParser extends ChangelogParser {
  TitleParser(Changelog changelog) : super(changelog);

  void onText(String text) {
    _ch.title = text;
  }
}
