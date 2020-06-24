import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class LinkFinder implements NodeVisitor {
  final links = <String>[];

  @override
  void visitElementAfter(Element element) {
    if (element.tag == 'a') {
      Maybe(element.attributes['href']).ifPresent(links.add);
    }
  }

  @override
  bool visitElementBefore(Element element) => true;

  @override
  void visitText(Text text) {}
}
