import 'package:flutter/material.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies(navigatorKey);
  runApp(const SnapNotesApp());
}
