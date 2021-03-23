import 'package:change/src/change.dart';

/// A release or the unreleased section
class Section {
  final _changes = <Change>[];

  /// Section link. Usually, the diff
  String link = '';

  /// Changes in the change set, optionally filtered by [type]
  Iterable<Change> changes([String type = '']) {
    if (type.isEmpty) return _changes;
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

  /// True if the section contains not changes
  bool get isEmpty => _changes.isEmpty;

  /// True if the section contains changes
  bool get isNotEmpty => _changes.isNotEmpty;

  /// Removes all changes
  void clear() {
    _changes.clear();
  }
}
