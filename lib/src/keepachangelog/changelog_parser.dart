import 'package:change/change.dart';
import 'package:markdown/markdown.dart';

part 'package:change/src/keepachangelog/block_parser.dart';

part 'package:change/src/keepachangelog/change_parser.dart';

part 'package:change/src/keepachangelog/manifest_parser.dart';

part 'package:change/src/keepachangelog/release_parser.dart';

part 'package:change/src/keepachangelog/title_parser.dart';

class ChangelogParser implements NodeVisitor {
  final Changelog _ch;
  final _path = List<String>();

  ChangelogParser(this._ch);

  static ChangelogParser byTag(String tag, Changelog c) {
    if (tag == 'h1') return TitleParser(c);
    if (tag == 'h2') return ReleaseParser(c);
    if (tag == 'h3') return BlockParser(c);
    if (tag == 'p') return ManifestParser(c);
    if (tag == 'ul') return ChangeParser(c);
    return ChangelogParser(c);
  }

  void onEnter(Element el) {}

  void onExit(Element el) {}

  void onText(String text) {}

  @override
  void visitText(Text text) => onText(text.textContent);

  @override
  void visitElementAfter(Element element) {
    onExit(element);
    _path.removeLast();
  }

  @override
  bool visitElementBefore(Element element) {
    _path.add(element.tag);
    onEnter(element);
    return true;
  }
}
