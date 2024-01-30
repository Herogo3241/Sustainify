import 'package:flutter/material.dart';
import 'package:social_code/Pages/SignUp.dart';
import 'package:social_code/firebase_options.dart';
import 'Utils/Navbar.dart';
import 'package:firebase_core/firebase_core.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  
}// Initialize Firebase
  


const MAINCOLOR = Color(0xff618264);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MAINCOLOR),
        useMaterial3: true,
      ),
      home: AuthenticationScreen(),
    );
  }
}


