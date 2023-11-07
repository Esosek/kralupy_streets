import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/hunting_street_provider.dart';

final db = FirebaseFirestore.instance;
final analytics = FirebaseAnalytics.instance;

class StreetProvider extends StateNotifier<List<Street>> {
  StreetProvider() : super([]);

  void loadStreets() async {
    List<Street> loadedStreets = [];
    try {
      final streetsData = await db.collection('streets').get();
      for (QueryDocumentSnapshot street in streetsData.docs) {
        // Handles database errors
        try {
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
          loadedStreets.add(newStreet);
        } catch (e) {
          analytics.logEvent(
              name: '${street['id']}_data_transformation_failed');
        }
      }
    } catch (e) {
      analytics.logEvent(name: 'streets_fetch_failed');
    }
    state = loadedStreets;
    analytics.logEvent(name: 'streets_loaded');
  }

  void addStreet(Street street) {
    state = [...state, street];
  }
}

final publicStreetProvider =
    StateNotifierProvider<StreetProvider, List<Street>>(
        (ref) => StreetProvider());

final streetProvider = Provider<List<Street>>((ref) {
  final publicStreets = ref.watch(publicStreetProvider);
  final huntingStreets = ref.watch(huntingStreetProvider);

  final transformedHuntingStreets =
      huntingStreets.where((street) => street.found).map(
            (street) => Street(
                id: street.id,
                name: street.name,
                imageUrl: street.imageUrl,
                geolocation: street.geolocation,
                descriptionParagraphs: street.descriptionParagraphs),
          );

  return [...publicStreets, ...transformedHuntingStreets];
});
