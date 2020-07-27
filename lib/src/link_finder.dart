import 'dart:collection';

import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// Collects links in a markdown document
class LinkCollector with IterableMixin<String> implements NodeVisitor {
  final _links = <String>[];

  @override
  void visitElementAfter(Element element) {
    if (element.tag == 'a') {
      Maybe(element.attributes['href']).ifPresent(_links.add);
    }
  }

  @override
  bool visitElementBefore(Element element) => true;

  @override
  void visitText(Text text) {}

  @override
  Iterator<String> get iterator => _links.iterator;
}
