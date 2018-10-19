part of 'package:change/src/keepachangelog/changelog_parser.dart';

class ManifestParser extends ChangelogParser {
  ManifestParser(Changelog changelog) : super(changelog) {
    changelog.manifest.add('');
  }

  void onText(String text) {
    changelog.manifest.last += text;
  }

  void onEnter(Element el) {
    if (el.tag == 'a') changelog.manifest.last += '[';
  }

  void onExit(Element el) {
    if (el.tag == 'a') {
      changelog.manifest.last += '](${el.attributes['href']})';
    }
  }
}
