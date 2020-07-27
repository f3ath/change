import 'package:change/src/inline_markdown.dart';
import 'package:markdown/markdown.dart';

class SectionBody extends Element {
  SectionBody(Iterable<InlineMarkdown> entries)
      : super('ul', entries.map((_) => Element('li', _.toMarkdown())).toList());
}
