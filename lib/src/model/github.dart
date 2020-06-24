import 'package:change/src/model/repo.dart';

class Github implements Repo {
  Github(this.user, this.repo);

  final String user;
  final String repo;

  @override
  String diffLink(String before, String after) =>
      'https://github.com/$user/$repo/compare/$before...$after';
}
