import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/instance_manager.dart';
import 'package:mob3_uas_klp_04/controllers/category_controller.dart';
import 'package:mob3_uas_klp_04/views/screens/authentification_screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '.env/anon_key.dart';
import 'firebase_options.dart';
import 'vendor/views/auth/vendor_login_screen.dart';
import 'vendor/views/screens/main_vendor_screen.dart';
import 'views/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: AnonKey.url,
    anonKey: AnonKey.anonKey,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      initialBinding: BindingsBuilder(
        () {
          Get.put<CategoryController>(CategoryController());
        },
      ),
    );
  }
}
