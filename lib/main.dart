import 'package:flutter/material.dart';
import 'package:kralupy_streets/screens/home_screen.dart';

final theme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC22011)),
    textTheme: const TextTheme(
      labelLarge: TextStyle(fontSize: 17),
      labelMedium: TextStyle(fontSize: 13),
    ));

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: const HomeScreen(),
    );
  }
}
