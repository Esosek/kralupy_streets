import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/screens/add_street.dart';
import 'package:kralupy_streets/screens/game_screen.dart';
import 'package:kralupy_streets/screens/streets_screen.dart';

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

  void _switchScreen(BuildContext context, Widget screenWidget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screenWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    ]),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1),
                        ),
                        child: Image.asset('assets/images/city_sign.png'),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: () => _switchScreen(
                          context,
                          GameScreen(
                            streets: streets,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Text(
                            'Nová hra',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () => _switchScreen(
                          context,
                          StreetScreen(
                            streets: streets,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Text(
                            'Ulice',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: () =>
                            _switchScreen(context, const AddStreet()),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          'Přidat novou ulici',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
