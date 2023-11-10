import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kralupy_streets/firebase_options.dart';
import 'package:kralupy_streets/screens/home_screen.dart';

final theme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC22011)),
    textTheme: GoogleFonts.barlowCondensedTextTheme().copyWith(
      labelLarge: GoogleFonts.barlowCondensedTextTheme().labelLarge!.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
      labelMedium: GoogleFonts.barlowCondensedTextTheme().labelMedium!.copyWith(
            fontSize: 15,
          ),
      labelSmall: GoogleFonts.barlowCondensedTextTheme().labelSmall!.copyWith(
            fontSize: 12,
          ),
    ));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp()
      : await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
  runApp(
    const ProviderScope(child: MainApp()),
  );
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
