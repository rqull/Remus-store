import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mob3_uas_klp_04/views/screens/authentification_screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mob3_uas_klp_04/views/screens/authentification_screens/register_screen.dart';
import 'package:mob3_uas_klp_04/views/screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
