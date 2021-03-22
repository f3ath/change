import 'package:change/src/anchor.dart';
import 'package:change/src/change.dart';
import 'package:change/src/section.dart';
import 'package:markdown/markdown.dart';

/// The unreleased section
class Unreleased extends Section {

  /// Diff link
  String? diff;
  @override
  Iterable<Node> toMarkdown() {
    final text = [Text('Unreleased')];
    final diff = this.diff;
    final header = diff != null ? [Anchor(diff, text)] : text;
    return <Node>[Element('h2', header)].followedBy(super.toMarkdown());
  }

}
