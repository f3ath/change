import 'dart:collection';

import 'package:change/change.dart';
import 'package:change/src/inline_markdown.dart';
import 'package:change/src/section_body.dart';
import 'package:change/src/section_title.dart';
import 'package:markdown/markdown.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// A set of changes of the same type.
class Section with IterableMixin<InlineMarkdown> {
  Section(this.type, [Iterable<InlineMarkdown>? entries]) {
    Maybe(entries).ifPresent(addAll);
  }

  /// The type of changes
  final ChangeType type;

  final _entries = <InlineMarkdown>[];

  /// Removes all entries.
  void clear() {
    _entries.clear();
  }

  /// Adds all [entries] to the group
  void addAll(Iterable<InlineMarkdown> entries) {
    _entries.addAll(entries);
  }

  /// Adds a plain text entry.
  void add(String text) {
    _entries.add(InlineMarkdown.parse(text));
  }

  /// Adds a markdown entry.
  void addMarkdown(InlineMarkdown markdown) {
    _entries.add(markdown);
  }

  @override
  int get length => _entries.length;

  @override
  Iterator<InlineMarkdown> get iterator => _entries.iterator;

  List<Element> toMarkdown() => [SectionTitle(type.name), SectionBody(this)];
}
