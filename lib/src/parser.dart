import 'package:change/changelog.dart';
import 'package:markdown/markdown.dart';

class Parser implements NodeVisitor {
  Element title;
  final List<Element> manifest = [];
  final List<Section> releases = [];

  @override
  void visitText(Text text) {}

  @override
  void visitElementAfter(Element element) {}

  @override
  bool visitElementBefore(Element element) {
    final actions = {
      'h1': () => title = element,
      'h2': () => releases.add(Section(element)),
      'h3': () => releases.last.groups.add(Group(element)),
      'p': () => manifest.add(element),
      'li': () => releases.last.groups.last.changes.add(element),
    };
    if (actions.containsKey(element.tag)) {
      actions[element.tag]();
      return false;
    }
    return true;
  }
}
