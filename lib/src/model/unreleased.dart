import 'package:change/src/model/collection.dart';
import 'package:change/src/model/link.dart';
import 'package:markdown/markdown.dart';

class Unreleased {
  final changes = Collection();
  String link = '';

  List<Element> toMarkdown() => [
        Element('h2', [_header]),
        ...changes.toMarkdown()
      ];

  Node get _header {
    final title = Text('Unreleased');
    if (link?.isNotEmpty == true) {
      return Link([title], link);
    }
    return title;
  }
}
