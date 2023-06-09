import 'package:change/src/change.dart';
import 'package:markdown/markdown.dart' show Node;

/// A release or the unreleased section
class Section {
  Section.copy(Section other)
      : _changes = other._changes,
        link = other.link,
        _header = other.header;

  final _changes = <Change>[];

  /// Section link. Usually, the diff
  String link = '';

  List<Node> _header = [];

  /// Changes in the change set, optionally filtered by [type]
  Iterable<Change> changes({String? type}) {
    if (type == null) return _changes;
    return _changes.where((_) => _.type == type);
  }

  /// Adds a change to the change set
  void add(Change change) {
    _changes.add(change);
  }

  /// Adds changes to the change set
  void addAll(Iterable<Change> changes) {
    _changes.addAll(changes);
  }

  /// Set header nodes
  void set setHeader(List<Node> header) {
    _header = header;
  }

  /// Get header nodes
  List<Node> get header {
    return _header;
  }

  /// True if the section contains not changes
  bool get isEmpty => _changes.isEmpty;

  /// True if the section contains changes
  bool get isNotEmpty => _changes.isNotEmpty;

  /// Removes all changes and the link
  void clear() {
    _changes.clear();
    link = '';
    setHeader = [];
  }
}
