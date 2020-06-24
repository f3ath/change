import 'package:args/command_runner.dart';

class CommandContainer<T> extends Command<T> {
  CommandContainer(this.name, this.description, List<Command<T>> commands) {
    commands.forEach(addSubcommand);
  }

  @override
  final String name;

  @override
  final String description;
}
