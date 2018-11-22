import 'dart:async';
import 'dart:io';

import 'package:change/src/parser.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart' as flavors;
import 'package:marker/marker.dart';

class Changelog {
  Element _title;
  List<Element> _manifest = [];
  List<Section> _sections = [];

  static Future<Changelog> fromFile(File file) async {
    final c = Changelog();
    final lines = await file.readAsLines();
    final nodes = Document().parseLines(lines);
    final parser = Parser();
    nodes.forEach((node) => node.accept(parser));
    c._title = parser.title;
    c._manifest.addAll(parser.manifest);
    c._sections.addAll(parser.releases);

    return c;
  }

  String toMarkdown() {
    return render(nodes, flavor: flavors.changelog);
  }

  List<Node> get nodes {
    final nodes = List<Node>()..addAll([_title] + _manifest);
    _sections.forEach((section) => nodes.addAll(section.nodes));
    return nodes;
  }

  void change(String description) => _add(Change('Changed', description));

  void deprecate(String description) => _add(Change('Deprecated', description));

  void _add(Change change) => unreleased.add(change);

  Section get unreleased =>
      _sections.firstWhere((rel) => rel.isUnreleased, orElse: () {
        _sections.insert(0, Section.unreleased());
        return _sections.first;
      });
}

class Group {
  Group(this._header);

  final Element _header;
  final List<Element> changes = [];

  List<Node> get nodes => [_header, Element('ul', changes)];

  void add(String description) =>
      changes.add(Element('li', [Text(description)]));

  bool hasType(String type) =>
      this._header.textContent.toLowerCase() == type.toLowerCase();
}

class Section {
  Section(this.title);

  Section.unreleased() : this(Element('h2', [Text('Unreleased')]));

  final Element title;
  final List<Group> groups = [];

  bool get isUnreleased => title.textContent.toLowerCase() == 'unreleased';

  void add(Change change) => groups
      .firstWhere(change.belongs, orElse: () => _addGroup(change.type))
      .add(change.description);

  List<Node> get nodes {
    final nodes = List<Node>()..add(title);
    groups.forEach((g) => nodes.addAll(g.nodes));
    return nodes;
  }

  Group _addGroup(String type) {
    groups.add(Group(Element('h3', [Text(type)])));
    return groups.last;
  }
}

class Change {
  final String description;
  final String type;

  Change(this.type, this.description);

  bool belongs(Group group) => group.hasType(type);
}
