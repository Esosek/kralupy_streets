import 'package:flutter/material.dart';

class AddStreet extends StatefulWidget {
  const AddStreet({super.key});

  @override
  State<AddStreet> createState() => _AddStreetState();
}

class _AddStreetState extends State<AddStreet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Přidat ulici'),
        ),
      ),
    );
  }
}
