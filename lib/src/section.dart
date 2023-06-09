import 'package:change/src/change.dart';
import 'package:markdown/markdown.dart';

/// A release or the unreleased section
class Section {
  final _changes = <Change>[];

  /// Free text which precedes the actual list of changes.
  /// The Keepachangelog standard does not specify this part but we support
  /// it since there's a demand for it.
  final preamble = <Element>[];

  /// Section link. Usually, the diff
  String link = '';

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

  /// True if the section contains not changes
  bool get isEmpty => _changes.isEmpty;

  /// True if the section contains changes
  bool get isNotEmpty => _changes.isNotEmpty;

  /// Removes all changes and the link
  void clear() {
    _changes.clear();
    link = '';
    preamble.clear();
  }
}
