import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/providers/street_provider.dart';

final db = FirebaseFirestore.instance;

class HuntingStreetProvider extends StateNotifier<List<HuntingStreet>> {
  HuntingStreetProvider() : super([]);

  // TODO: localStorage of found streets and end timestamp of the current hunting
  // TODO: Clear localStorage if hunting ended
  void loadHuntingStreets() async {
    final currentTimestamp = _getCurrentTimestamp();
    debugPrint('Current time: $currentTimestamp');
    try {
      final futureHuntings = await db
          .collection('hunting')
          .where('end', isGreaterThan: currentTimestamp)
          .get();

      final currentHunting = futureHuntings.docs
          .where((hunt) => hunt['start'] <= currentTimestamp)
          .toList();

      final List<dynamic> streetsSnapshots = currentHunting[0]['streets'];

      final List<HuntingStreet> huntingStreets = [];
      for (var snapshot in streetsSnapshots) {
        try {
          final street = HuntingStreet(
            id: snapshot['id'],
            name: snapshot['name'],
            imageUrl: snapshot['imageUrl'],
            geolocation: Geolocation(
              latitude: snapshot['geolocation']['lat'],
              longitude: snapshot['geolocation']['lng'],
            ),
            descriptionParagraphs:
                List<String>.from(snapshot['descriptionParagraphs']),
          );
          huntingStreets.add(street);
        } catch (e) {
          debugPrint('HuntingStreet transformation failed: $e');
        }
      }

      state = huntingStreets;
      debugPrint('HuntingStreets successfully loaded');
    } catch (e) {
      debugPrint('Fetching hunting failed: $e');
    }
  }

  void huntStreet(int streetId) {
    final now = DateTime.now();
    final formattedDate = '${now.day}.${now.month}.${now.year}';

    final updatedHunt = state.map((street) {
      if (street.id == streetId) {
        return street.copyWith(found: true, foundDate: formattedDate);
      }
      return street;
    }).toList();

    state = updatedHunt;
    // TODO: Store it in localStorage alongisde timestamp of end
  }

  int _getCurrentTimestamp() {
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    // Convert to seconds
    int secondsSinceEpoch = (millisecondsSinceEpoch / 1000).round();
    return secondsSinceEpoch;
  }
}

final huntingStreetProvider =
    StateNotifierProvider<HuntingStreetProvider, List<HuntingStreet>>(
        (ref) => HuntingStreetProvider());
