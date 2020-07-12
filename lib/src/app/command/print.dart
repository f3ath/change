import 'package:change/src/app/command/app_command.dart';
import 'package:change/src/app/console.dart';

class Print extends AppCommand {
  Print(this.console);

  final Console console;

  @override
  String get description => 'Prints changes for a released version';

  @override
  String get name => 'print';

  @override
  Future<int> run() async {
    if (argResults.rest.isEmpty) {
      console.error('Please specify released version to print.');
      return 1;
    }
    return await app().print(argResults.rest.first, console);
  }
}
