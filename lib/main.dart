import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/smart_pune_commute_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Properly initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBg_RTmarazPsYaZcLVehBFhlZcg_BiRY4",
      appId: "1:879145792646:android:c1f83c45d1fdcd54b84d07",
      messagingSenderId: "879145792646",
      projectId: "majorproject-c724e",
    ),
  );

  runApp( SmartPuneCommuteApp());
}
