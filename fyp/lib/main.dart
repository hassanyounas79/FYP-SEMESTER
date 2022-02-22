import 'package:flutter/material.dart';
import 'package:fyp/screens/Student.dart';
import 'package:fyp/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fyp/screens/admin.dart';
import 'package:fyp/screens/supervisor.dart';
import 'package:fyp/screens/test.dart';

import 'screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    ),
  );
}
