import 'package:markdown/markdown.dart';

class ChangeSetTitle extends Element {
  ChangeSetTitle(List<Node> children) : super('h2', children);
}
