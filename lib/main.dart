import 'package:exprimo/constants.dart';
import 'package:exprimo/login/login_screen.dart';
import 'package:exprimo/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //menghilangkan banner debug
      title: 'Flutter Auth',
      theme: ThemeData(
        primaryColor: secondaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),
    );
  }
}
