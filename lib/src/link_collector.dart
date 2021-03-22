import 'dart:collection';

import 'package:markdown/markdown.dart';

/// Collects links in a markdown document
class LinkCollector with IterableMixin<String> implements NodeVisitor {
  final _links = <String>[];

  @override
  void visitElementAfter(Element element) {
    if (element.tag == 'a') {
      final href = element.attributes['href'];
      if (href != null) _links.add(href);
    }
  }

  @override
  bool visitElementBefore(Element element) => true;

  @override
  void visitText(Text text) {}

  @override
  Iterator<String> get iterator => _links.iterator;
}
