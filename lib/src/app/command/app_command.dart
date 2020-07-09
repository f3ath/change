import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:change/src/app/change_app.dart';

abstract class AppCommand extends Command<int> {
  ChangeApp app() => ChangeApp(File(globalResults['changelog-path']));
}
