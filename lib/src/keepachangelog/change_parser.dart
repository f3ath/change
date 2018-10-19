part of 'package:change/src/keepachangelog/changelog_parser.dart';

class ChangeParser extends ChangelogParser {
  ChangeParser(Changelog changelog) : super(changelog);

  void onText(String text) {
    _ch.releases.last.blocks.last.changes.last += text;
  }

  void onEnter(Element el) {
    if (el.tag == 'li') _ch.releases.last.blocks.last.changes.add('');
    if (el.tag == 'a') _ch.releases.last.blocks.last.changes.last += '[';
  }

  void onExit(Element el) {
    if (el.tag == 'a') {
      _ch.releases.last.blocks.last.changes.last +=
          '](${el.attributes['href']})';
    }
  }
}
