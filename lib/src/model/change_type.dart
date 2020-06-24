/// A type of change
abstract class ChangeType {
  const ChangeType(this.name);

  /// Addition. A new feature.
  static const ChangeType addition = _Addition();

  /// Change. A change in existing functionality.
  static const ChangeType change = _Change();

  /// Deprecation. A soo-to-be removed feature.
  static const ChangeType deprecation = _Deprecation();

  /// Removal. A removed feature.
  static const ChangeType removal = _Removal();

  /// Fix. A bug fix.
  static const ChangeType fix = _Fix();

  /// Security. In case of vulnerabilities.
  static const ChangeType security = _Security();

  /// All possible types.
  static const List<ChangeType> all = [
    addition,
    change,
    deprecation,
    removal,
    fix,
    security
  ];

  /// Returns the [ChangeType] which matches the [text].
  static ChangeType fromString(String text) =>
      all.firstWhere((_) => _.match(text),
          orElse: () => throw 'Unrecognized change type "$text"');

  /// Capitalized block name. E.g. "Added", "Removed", etc.
  final String name;

  /// Returns true if the [text] matches the change type.
  bool match(String text);
}

class _Addition extends ChangeType {
  const _Addition() : super('Added');

  @override
  bool match(String text) => text.toLowerCase().startsWith('add');
}

class _Change extends ChangeType {
  const _Change() : super('Changed');

  @override
  bool match(String text) => text.toLowerCase().startsWith('ch');
}

class _Deprecation extends ChangeType {
  const _Deprecation() : super('Deprecated');

  @override
  bool match(String text) => text.toLowerCase().startsWith('dep');
}

class _Removal extends ChangeType {
  const _Removal() : super('Removed');

  @override
  bool match(String text) => text.toLowerCase().startsWith('rem');
}

class _Fix extends ChangeType {
  const _Fix() : super('Fixed');

  @override
  bool match(String text) => text.toLowerCase().startsWith('fix');
}

class _Security extends ChangeType {
  const _Security() : super('Security');

  @override
  bool match(String text) => text.toLowerCase().startsWith('sec');
}
