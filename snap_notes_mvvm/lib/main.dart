import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snap_notes_mvvm/core/di/injection.dart';
import 'package:snap_notes_mvvm/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Background tembus pandang
      statusBarIconBrightness: Brightness.dark, // Ikon hitam (baterai, sinyal)
      systemNavigationBarColor: Colors.white, // Navbar putih
      systemNavigationBarIconBrightness: Brightness.dark, // Ikon navbar hitam
    ),
  );

  await initDependencies(navigatorKey);
  runApp(const SnapNotesApp());
}
