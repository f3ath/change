import 'package:args/command_runner.dart';

class Container<T> extends Command<T> {
  Container(this.name, this.description, List<Command<T>> commands) {
    commands.forEach(addSubcommand);
  }

  @override
  final String name;

  @override
  final String description;
}
