import 'dart:io';

import 'package:flutter/material.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/widgets/image_input.dart';
import 'package:kralupy_streets/widgets/location_input.dart';

class AddStreet extends StatefulWidget {
  const AddStreet({super.key});

  @override
  State<AddStreet> createState() => _AddStreetState();
}

class _AddStreetState extends State<AddStreet> {
  final _streetNameController = TextEditingController();
  late FocusNode _streetNameFocusNode;
  bool _isEditingName = false;

  Geolocation? _geolocation;
  File? _streetPicture;

  void _setLocation(
      {required Geolocation geolocation, required String streetName}) {
    _geolocation = geolocation;
    _streetNameController.text = streetName;
  }

  void _submitStreet() async {
    // Send to Firebase
    Navigator.of(context).pop();
    // Show snackbar
  }

  @override
  void initState() {
    super.initState();
    _streetNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _streetNameController.dispose();
    _streetNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Přidat ulici'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _submitStreet,
          child: const Icon(Icons.send_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageInput(
                onPickImage: (selectedPicture) =>
                    _streetPicture = selectedPicture,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: TextField(
                      focusNode: _streetNameFocusNode,
                      controller: _streetNameController,
                      enabled: _isEditingName,
                      onEditingComplete: () =>
                          setState(() => _isEditingName = false),
                      keyboardType: TextInputType.name,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLength: 30,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Název',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (!_isEditingName)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditingName = true;
                        });
                        Future.delayed(const Duration(milliseconds: 50), () {
                          _streetNameFocusNode.requestFocus();
                        });
                      },
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              LocationInput(onLocationSet: _setLocation),
            ],
          ),
        ),
      ),
    );
  }
}
