import 'package:change/src/changelog.dart';
import 'package:change/src/release.dart';
import 'package:change/src/section.dart';
import 'package:intl/intl.dart';
import 'package:markdown/markdown.dart';
import 'package:marker/flavors.dart' as flavors;
import 'package:marker/marker.dart';

/// Converts the [changelog] to a markdown string.
/// - [keepEmptyUnreleased] preserves the "Unreleased" section even when it's empty
String printChangelog(Changelog changelog,
        {bool keepEmptyUnreleased = false}) =>
    render(_changelog(changelog, keepEmptyUnreleased: keepEmptyUnreleased),
        flavor: flavors.changelog);

/// Converts the [release] to a markdown string.
String printRelease(Release release) => render(
      _release(release),
      flavor: flavors.changelog,
    );

/// Converts the [unreleased] section to a markdown string.
String printUnreleased(Section unreleased) => render(
      _unreleased(unreleased),
      flavor: flavors.changelog,
    );

final _iso8601 = DateFormat('yyyy-MM-dd');

Iterable<Node> _changelog(Changelog log,
    {bool keepEmptyUnreleased = false}) sync* {
  yield* log.header;
  if (log.unreleased.isNotEmpty || keepEmptyUnreleased) {
    yield* _unreleased(log.unreleased);
  }
  yield* log.history().toList().reversed.expand(_release);
}

Iterable<Element> _unreleased(Section section) sync* {
  final header = <Node>[];
  final text = Text('Unreleased');
  final sectionLink = section.link;
  if (sectionLink.isEmpty) {
    header.add(text);
  } else {
    header.add(_link(sectionLink, [text]));
  }
  yield Element('h2', header);
  yield* _changes(section);
}

Iterable<Element> _release(Release section) sync* {
  final header = <Node>[];
  final dateSuffix = ' - ' + _iso8601.format(section.date);
  final sectionLink = section.link;
  if (sectionLink.isNotEmpty) {
    header.add(_link(sectionLink, [Text(section.version.toString())]));
    header.add(Text(dateSuffix));
  } else {
    header.add(Text(section.version.toString() + dateSuffix));
  }
  yield Element('h2', header);
  yield* _changes(section);
}

Iterable<Element> _changes(Section section) sync* {
  final types = Set.of(section.changes().map((e) => e.type)).toList();
  types.sort();
  for (final type in types) {
    final items = section.changes(type: type);
    if (items.isNotEmpty) {
      yield Element('h3', [Text(type)]);
      yield Element('ul',
          items.map((e) => Element('li', e.description.toList())).toList());
    }
  }
}

Element _link(String link, List<Node> text) =>
    Element('a', text)..attributes['href'] = link;
