part of 'package:change/src/keepachangelog/changelog_parser.dart';

class BlockParser extends ChangelogParser {
  BlockParser(Changelog changelog) : super(changelog) {
    changelog.releases.last.blocks.add(Block());
  }

  void onText(String text) {
    changelog.releases.last.blocks.last.type = text;
  }
}
