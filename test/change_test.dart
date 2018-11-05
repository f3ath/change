import 'dart:async';
import 'dart:io';

import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart' as flavors;
import 'package:marker/marker.dart';
import 'package:test/test.dart';

void main() {
//  group('Parsing', () {
//    test('Can load example and write it back unchanged', () async {
//      final file = File('test/keepachangelog.md');
//      final changelog = await Changelog.fromFile(file);
//      final markdown = changelog.toMarkdown();
//
//      expect(markdown, equals(file.readAsStringSync()));
//    });
//  });

  group('Manipulation', () {
    final step01 = File('test/example/step01.md');
    final step02 = File('test/example/step02.md');

    test('Can add an unreleased change', () async {
      final cl = await Changelog.fromFile(step01);
      cl.change('Programmatically added change');
      cl.deprecate('Programmatically added deprecation');
      expect(cl.toMarkdown(), equals(step02.readAsStringSync()));
    });
  });
}

class Changelog {
  Element _title;
  List<Element> _manifest = [];
  List<Release> _releases = [];

  static Future<Changelog> fromFile(File file) async {
    final c = Changelog();
    final lines = await file.readAsLines();
    final nodes = Document().parseLines(lines);
    final parser = Parser();
    nodes.forEach((node) => node.accept(parser));
    c._title = parser.title;
    c._manifest.addAll(parser.manifest);
    c._releases.addAll(parser.releases);

    return c;
  }

  String toMarkdown() {
    final List<Node> nodes = [_title];
    nodes.addAll(_manifest);
    _releases.forEach((rel) {
      nodes.add(rel.title);
      rel.changesets.forEach((set) {
        nodes.add(set.type);
        nodes.add(Element('ul', set.changes));
      });
    });
    return render(nodes, flavor: flavors.changelog);
  }

  void change(String description) {
    Release release = _releases.firstWhere(
        (rel) => rel.title.textContent.toLowerCase() == 'unreleased',
        orElse: () => null);
    if (release == null) {
      release = Release(Element('h2', [Text('Unreleased')]));
      _releases.insert(0, release);
    }
    Changeset set = release.changesets.firstWhere(
        (s) => s.type.textContent.toLowerCase() == 'changed',
        orElse: () => null);
    if (set == null) {
      set = Changeset(Element('h3', [Text('Changed')]));
      release.changesets.add(set);
    }
    set.changes.add(Element('li', [Text(description)]));
  }

  void deprecate(String description) {
    Release release = _releases.firstWhere(
        (rel) => rel.title.textContent.toLowerCase() == 'unreleased',
        orElse: () => null);
    if (release == null) {
      release = Release(Element('h2', [Text('Unreleased')]));
      _releases.insert(0, release);
    }
    Changeset set = release.changesets.firstWhere(
        (s) => s.type.textContent.toLowerCase() == 'deprecated',
        orElse: () => null);
    if (set == null) {
      set = Changeset(Element('h3', [Text('Deprecated')]));
      release.changesets.add(set);
    }
    set.changes.add(Element('li', [Text(description)]));
  }
}

class Parser implements NodeVisitor {
  Element title;
  final List<Element> manifest = [];
  final List<Release> releases = [];

  @override
  void visitText(Text text) {}

  @override
  void visitElementAfter(Element element) {}

  @override
  bool visitElementBefore(Element element) {
    if (element.tag == 'h1') {
      title = element;
      return false;
    }
    if (element.tag == 'p') {
      manifest.add(element);
      return false;
    }
    if (element.tag == 'h2') {
      releases.add(Release(element));
      return false;
    }
    if (element.tag == 'h3') {
      releases.last.changesets.add(Changeset(element));
      return false;
    }
    if (element.tag == 'li') {
      releases.last.changesets.last.changes.add(element);
      return false;
    }

    return true;
  }
}

class Changeset {
  Changeset(this.type);

  final Element type;
  final List<Element> changes = [];
}

class Release {
  Release(this.title);

  final Element title;
  final List<Changeset> changesets = [];
}
