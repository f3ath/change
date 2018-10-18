import 'package:change/change.dart';
import 'package:markdown/markdown.dart';

Changelog parseLines(List<String> lines) {
  final changelog = Changelog();
  final nodes = Document().parseLines(lines);
  nodes.forEach((n) {
    if (n is Element) {
      n.accept(Parser.byTag(n.tag, changelog));
    }
  });
  return changelog;
}

class Parser implements NodeVisitor {
  final Changelog changelog;

  Parser(this.changelog);

  static Parser byTag(String tag, Changelog c) {
    if (tag == 'h1') return TitleParser(c);
    if (tag == 'h2') return ReleaseParser(c);
    if (tag == 'h3') return BlockParser(c);
    if (tag == 'p') return ManifestParser(c);
    if (tag == 'ul') return ChangeParser(c);
    return Parser(c);
  }

  void onEnter(Element el) {}

  void onExit(Element el) {}

  void onText(String text) {}

  @override
  void visitText(Text text) => onText(text.textContent);

  @override
  void visitElementAfter(Element element) => onExit(element);

  @override
  bool visitElementBefore(Element element) {
    onEnter(element);
    return true;
  }
}

class TitleParser extends Parser {
  TitleParser(Changelog changelog) : super(changelog);

  void onText(String text) {
    changelog.title = text;
  }
}

class ManifestParser extends Parser {
  ManifestParser(Changelog changelog) : super(changelog) {
    changelog.manifest.paragraphs.add('');
  }

  void onText(String text) {
    changelog.manifest.paragraphs.last += text;
  }

  void onEnter(Element el) {
    if (el.tag == 'a') changelog.manifest.paragraphs.last += '[';
  }

  void onExit(Element el) {
    if (el.tag == 'a') {
      changelog.manifest.paragraphs.last += '](${el.attributes['href']})';
    }
  }
}

class ReleaseParser extends Parser {
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
      changelog.releases.last.link = el.attributes['href'];
    }
  }
}

class BlockParser extends Parser {
  BlockParser(Changelog changelog) : super(changelog) {
    changelog.releases.last.blocks.add(Block());
  }

  void onText(String text) {
    changelog.releases.last.blocks.last.type = text;
  }
}

class ChangeParser extends Parser {
  ChangeParser(Changelog changelog) : super(changelog);

  void onText(String text) {
    changelog.releases.last.blocks.last.changes.last += text;
  }

  void onEnter(Element el) {
    if (el.tag == 'li') changelog.releases.last.blocks.last.changes.add('');
    if (el.tag == 'a') changelog.releases.last.blocks.last.changes.last += '[';
  }

  void onExit(Element el) {
    if (el.tag == 'a') {
      changelog.releases.last.blocks.last.changes.last +=
          '](${el.attributes['href']})';
    }
  }
}
