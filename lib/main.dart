import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kralupy_streets/screens/home_screen.dart';

final theme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC22011)),
    textTheme: GoogleFonts.barlowCondensedTextTheme().copyWith(
      labelLarge: const TextStyle(fontSize: 17),
      labelMedium: const TextStyle(fontSize: 13),
      labelSmall: const TextStyle(fontSize: 11),
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
