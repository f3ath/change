import 'package:markdown/markdown.dart';

class Anchor extends Element {
  Anchor(String href, List<Node> children) : super('a', children) {
    attributes['href'] = href;
  }
}
