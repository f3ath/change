import 'dart:io';

import 'package:change/app.dart';

void main(List<String> args) async =>
    exit((await buildApp(Console.stdio()).run(args)) ?? 0);
