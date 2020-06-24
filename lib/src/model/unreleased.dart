import 'package:change/src/model/collection.dart';
import 'package:change/src/model/link.dart';
import 'package:markdown/markdown.dart';

class Unreleased extends Collection {
  @override
  List<Element> toMarkdown() => [
        Element('h2', [_header]),
        ...super.toMarkdown()
      ];

  Node get _header {
    final title = Text('Unreleased');
    if (link?.isNotEmpty == true) {
      return Link([title], link);
    }
    return title;
  }
}
