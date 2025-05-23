import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'screens/splash_screen.dart';
import 'screens/photo_page.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyBWJ0_-ZAKAi2QAYVnD8umem9gFmHYzUKU');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blueGrey[800],
        scaffoldBackgroundColor: Colors.white70,
      ),
      title: 'Receipt Hacker',
      color: Colors.white,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/photo': (context) => PhotoPage(),
      },
    );
  }
}
