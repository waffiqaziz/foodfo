import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodfo/app_root.dart';
import 'package:foodfo/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AppRoot());
}
