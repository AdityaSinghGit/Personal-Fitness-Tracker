// App entry: Flutter binding, Hive, then the fitness app.

import 'package:flutter/material.dart';
import 'package:personal_fitness_tracker/app.dart';
import 'package:personal_fitness_tracker/core/bootstrap/hive_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  runApp(const FitnessApp());
}
