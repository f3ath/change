import 'package:markdown/markdown.dart';

class SectionTitle extends Element {
  SectionTitle(String text) : super('h3', [Text(text)]);
}
