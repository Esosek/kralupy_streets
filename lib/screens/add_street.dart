import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/widgets/ui/image_input.dart';
import 'package:kralupy_streets/widgets/ui/location_input.dart';

final db = FirebaseFirestore.instance;
final fcm = FirebaseMessaging.instance;
final analytics = FirebaseAnalytics.instance;

class AddStreet extends StatefulWidget {
  const AddStreet({super.key});

  @override
  State<AddStreet> createState() => _AddStreetState();
}

class _AddStreetState extends State<AddStreet> {
  final _streetNameController = TextEditingController();
  late FocusNode _streetNameFocusNode;
  bool _isEditingName = false;
  bool _isSending = false;
  String? _fetchedStreetName;

  Geolocation? _geolocation;
  File? _streetImage;
  String? _streetImageUrl;
  String? _userToken;

  void _setLocation(
      {required Geolocation geolocation, required String streetName}) {
    _geolocation = geolocation;
    _streetNameController.text = streetName;
    _fetchedStreetName = streetName;

    analytics.logEvent(
      name: 'new_street_location_stored',
      parameters: {
        'name': _fetchedStreetName,
      },
    );
  }

  void _submitStreet() async {
    // Validate input
    if (_streetImage == null ||
        _geolocation == null ||
        _streetNameController.text.length < 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chybná data'),
          content: const Text(
              'Nahrajte prosím obrázek ulice, její lokaci a validní název.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _isSending = true;
    });
    await _uploadImage();
    await db.collection('suggestions').add(
      {
        'name': _streetNameController.text,
        'geolocation': {
          'lat': _geolocation!.latitude,
          'lng': _geolocation!.longitude,
        },
        'imageUrl': _streetImageUrl,
        'deviceId': _userToken ?? '',
      },
    );
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Požadavek na přidání ulice "${_streetNameController.text}" byl odeslán. Děkujeme!'),
      ),
    );
    analytics.logEvent(
      name: 'new_street_submitted',
      parameters: {
        'street_name': _streetNameController.text,
      },
    );
  }

  Future<void> _uploadImage() async {
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('suggestion_images')
        .child(
            '${_streetNameController.text}_latlng=${_geolocation!.latitude},${_geolocation!.longitude}.jpg');

    await imageRef.putFile(_streetImage!);
    return;
  }

  void _setupNotifications() async {
    await fcm.requestPermission();
    _userToken = await fcm.getToken();
  }

  @override
  void initState() {
    super.initState();
    _setupNotifications();
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
        floatingActionButton: _isSending
            ? const CircularProgressIndicator()
            : FloatingActionButton(
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
                    _streetImage = selectedPicture,
              ),
              const SizedBox(height: 16),
              LocationInput(onLocationSet: _setLocation),
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
                      onEditingComplete: () {
                        analytics.logEvent(
                          name: 'new_street_name_changed',
                          parameters: {
                            'old_name': _fetchedStreetName ?? 'null',
                            'new_name': _streetNameController.text,
                          },
                        );
                        setState(() => _isEditingName = false);
                      },
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
            ],
          ),
        ),
      ),
    );
  }
}
