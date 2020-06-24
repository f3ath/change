import 'package:markdown/markdown.dart';

class Link extends Element {
  Link(List<Node> children, String href) : super('a', children) {
    attributes['href'] = href;
  }
}
