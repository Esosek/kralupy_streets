import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/street.dart';

final db = FirebaseFirestore.instance;

class HuntingStreetProvider extends StateNotifier<List<HuntingStreet>> {
  HuntingStreetProvider() : super([]);

  // TODO: localStorage of found streets and end timestamp of the current hunting
  // TODO: Clear localStorage if hunting ended
  void loadStreets() async {
    final currentTimestamp = _getCurrentTimestamp();
    try {
      final currentHunting = await db
        .collection('hunting')
        .where('start', isLessThanOrEqualTo: currentTimestamp)
        .where('end', isGreaterThan: currentTimestamp)
        .get();

        // TODO: Transform and store streets from active hunting to state
        final List<Map<String, dynamic>> streetsSnapshots = currentHunting.docs[0]['streets'];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void solveStreet(int streetId) {
    // TODO: Toggle found attribute of the street
    // TODO: Store it in localStorage alongisde timestamp of end
  }

  int _getCurrentTimestamp() {
    int secondsSinceEpoch = DateTime.now().second;
    debugPrint(secondsSinceEpoch.toString());
    return secondsSinceEpoch;
  }
}

final huntingStreetProvider =
    StateNotifierProvider<HuntingStreetProvider, List<HuntingStreet>>(
        (ref) => HuntingStreetProvider());
