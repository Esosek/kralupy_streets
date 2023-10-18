import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/widgets/home_buttons.dart';

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
    try {
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
        analytics.logEvent(name: 'streets_loaded');
      }
    } catch (e) {
      analytics.logEvent(name: 'streets_fetch_failed');
    }

    setState(() {
      _isLoading = false;
    });
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
                  child: Flex(
                    direction: isLandscape ? Axis.horizontal : Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: isLandscape
                            ? MediaQuery.of(context).size.width * 0.25
                            : MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1),
                        ),
                        child: Image.asset(
                          'assets/images/city_sign.png',
                        ),
                      ),
                      const SizedBox(
                        width: 60,
                        height: 60,
                      ),
                      HomeButtons(streets: streets)
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
