import 'package:change/src/app/command/app_command.dart';
import 'package:change/src/app/console.dart';

class Release extends AppCommand {
  Release(this.console);

  final Console console;
  String link = '';

  @override
  String get description => 'Creates a new release section from Unreleased';

  @override
  String get name => 'release';

  @override
  Future<int> run() async {
    if (argResults.arguments.isEmpty) {
      console.error('Please specify release version.');
      return 1;
    }
    await app().release(argResults.arguments.first, globalResults['date'],
        globalResults['link']);
    return 0;
  }
}
