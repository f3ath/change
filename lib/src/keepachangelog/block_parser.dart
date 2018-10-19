part of 'package:change/src/keepachangelog/changelog_parser.dart';

class BlockParser extends ChangelogParser {
  BlockParser(Changelog changelog) : super(changelog) {}

  void onText(String text) {
    _ch.releases.last.blocks.add(Block(text));
  }
}
