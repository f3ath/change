class LinkTemplate {
  LinkTemplate(this.template);

  final String template;

  String format(String from, String to) =>
      template.replaceAll('%from%', from).replaceAll('%to%', to);
}
