import 'package:flutter/material.dart';

class StreetScreen extends StatelessWidget {
  const StreetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ulice'),
        ),
      ),
    );
  }
}
