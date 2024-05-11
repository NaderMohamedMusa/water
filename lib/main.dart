import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:water/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  await Firebase.initializeApp();
  runApp(
    const MaterialApp(
        title: 'Water quality',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
  );
}