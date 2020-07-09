import 'package:change/model.dart';
import 'package:change/src/app/command/app_command.dart';
import 'package:change/src/app/console.dart';

class Add extends AppCommand {
  Add(this.console, this.type, this.name);

  final ChangeType type;
  final Console console;
  @override
  final String name;

  @override
  String get description =>
      'Adds a new change to Unreleased ${type.name} section';

  @override
  Future<int> run() async {
    if (argResults.arguments.isEmpty) {
      console.error('Too few arguments');
      return 1;
    }
    await app().add(type, argResults.arguments.first);
    return 0;
  }
}
