import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/widgets/home_screen/home_buttons.dart';
import 'package:kralupy_streets/widgets/home_screen/home_image.dart';

final db = FirebaseFirestore.instance;
final analytics = FirebaseAnalytics.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  final List<Street> streets = [];

  void _loadStreets() async {
    final streetsData = await db.collection('streets').get();
    for (QueryDocumentSnapshot street in streetsData.docs) {
      final newStreet = Street(
        id: street['id'],
        name: street['name'],
        imageUrl: street['imageUrl'],
        descriptionParagraphs: street['descriptionParagraphs'] == null
            ? []
            : List<String>.from(street['descriptionParagraphs']),
        geolocation: Geolocation(
          latitude: street['geolocation']['lat'],
          longitude: street['geolocation']['lng'],
        ),
      );
      streets.add(newStreet);
    }
    setState(() {
      _isLoading = false;
    });

    analytics.logEvent(name: 'streets_loaded');
  }

  @override
  void initState() {
    _loadStreets();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fetching streets data...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: isLandscape
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const HomeImage(),
                            const SizedBox(width: 160),
                            HomeButtons(streets: streets)
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const HomeImage(),
                            const SizedBox(height: 60),
                            HomeButtons(streets: streets),
                          ],
                        ),
                ),
              ),
      ),
    );
  }
}
