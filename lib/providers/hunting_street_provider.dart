import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kralupy_streets/models/geolocation.dart';
import 'package:kralupy_streets/models/street.dart';
import 'package:kralupy_streets/utils/custom_logger.dart';
import 'package:kralupy_streets/utils/storage_helper.dart';

final db = FirebaseFirestore.instance;

class HuntingStreetProvider extends StateNotifier<List<HuntingStreet>> {
  HuntingStreetProvider() : super([]);

  static const huntTimestampKey = 'huntTimestamp';
  static const huntStreetsIdsKey = 'huntStreetsIds';

  final storage = StorageHelper();
  final log = CustomLogger('HuntingStreetProvider');

  void loadHuntingStreets() async {
    try {
      final currentHunting = await _getCurrentHunting();
      final List<dynamic> streetsSnapshots = currentHunting['streets'];

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
            keywords: (snapshot['keywords'] as List<dynamic>)
                .map<String>((dynamic keyword) {
              // Type cast each keyword to a String
              return keyword.toString();
            }).toList(),
            finder: snapshot['finder'],
          );
          huntingStreets.add(street);
        } catch (e) {
          log.error('HuntingStreet transformation failed: $e');
        }
      }

      state = await _getLocalStreets(huntingStreets, currentHunting['end']);
      log.info('HuntingStreets successfully loaded');
    } catch (e) {
      log.error('Fetching hunting failed: $e');
      log.trace('No active hunt, clear stored data');
      _clearStoredData();
    }
  }

  void huntStreet(int streetId, String? username) {
    final now = DateTime.now();
    final formattedDate = '${now.day}.${now.month}.${now.year}';

    final updatedHunt = state.map((street) {
      if (street.id == streetId) {
        return street.copyWith(
          found: true,
          foundDate: formattedDate,
          finder: street.finder ?? username,
        );
      }
      return street;
    }).toList();

    state = updatedHunt;

    if (username != null) {
      // User is first and valid nickname was stored
      _storeFinder(streetId, username);
    }

    storage.setStringValue(streetId.toString(), formattedDate);
    storage.addIntToList(huntStreetsIdsKey, streetId);
  }

  Future<bool> hasFinder(int streetId) async {
    try {
      final currentHunt = await _getCurrentHunting();
      final List<dynamic> streetsSnapshots = currentHunt['streets'];

      for (var streetSnapshot in streetsSnapshots) {
        if (streetSnapshot['id'] == streetId) {
          if (streetSnapshot['finder'] != null) {
            log.trace(
                'Street $streetId has finder ${streetSnapshot['finder']} already');
            return true;
          }
        }
      }
      log.trace('No finder found for street $streetId');
      return false;
    } catch (e) {
      log.error('Checking street finder failed: $e');
      return true;
    }
  }

  Future<Map<String, dynamic>> _getCurrentHunting() async {
    final currentTimestamp = _getCurrentTimestamp();
    log.trace('Current time: $currentTimestamp');
    try {
      final futureHuntings = await db
          .collection('hunting')
          .where('end', isGreaterThan: currentTimestamp)
          .get();

      final huntDocs = futureHuntings.docs
          .where((hunt) => hunt['start'] <= currentTimestamp)
          .toList();
      if (huntDocs.isNotEmpty) {
        return {
          'id': huntDocs[0].id,
          ...huntDocs[0].data(),
        };
      } else {
        log.warning('No active hunting found');
        return {};
      }
    } catch (e) {
      log.error('Failed to fetch active hunting: $e');
      return {};
    }
  }

  Future<void> _storeFinder(int streetId, String username) async {
    final formattedUsername =
        username[0].toUpperCase() + username.substring(1).toLowerCase();
    final currentHunting = await _getCurrentHunting();
    final List<dynamic> streetsSnapshots = currentHunting['streets'];
    // Modifies the finder field for the active street
    for (var street in streetsSnapshots) {
      if (street['id'] == streetId) {
        street['finder'] = formattedUsername;
      }
    }

    try {
      db
          .collection('hunting')
          .doc(currentHunting['id'])
          .update({'streets': streetsSnapshots});

      log.trace('Updated street $streetId with finder "$username"');
    } catch (e) {
      log.trace('Updating street finder failed: $e');
    }
  }

  int _getCurrentTimestamp() {
    int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    // Convert to seconds
    int secondsSinceEpoch = (millisecondsSinceEpoch / 1000).round();
    return secondsSinceEpoch;
  }

  Future<List<HuntingStreet>> _getLocalStreets(
      List<HuntingStreet> fetchedStreets, int activeHuntEnd) async {
    log.trace('Active hunt ends $activeHuntEnd');
    final storedTimestamp = _getStoredTimestamp();
    final storedHuntStreetsIds = _getStoredHuntStreetsIds();

    if (storedTimestamp == null) {
      log.trace('No timestamp found, storing current');
      storage.setIntValue(huntTimestampKey, activeHuntEnd);
      return fetchedStreets;
    }

    if (storedTimestamp != activeHuntEnd) {
      log.info('Hunt ended, clearing stored data');
      await _clearStoredData();
      storage.setIntValue(huntTimestampKey, activeHuntEnd);
      return fetchedStreets;
    }

    log.info('Updating streets with local records');
    return _updateFoundStatus(fetchedStreets, storedHuntStreetsIds);
  }

  int? _getStoredTimestamp() {
    return storage.getIntValue(huntTimestampKey);
  }

  List<int>? _getStoredHuntStreetsIds() {
    return storage.getListIntValue(huntStreetsIdsKey);
  }

  Future<void> _clearStoredData() async {
    final storedHuntStreetsIds = _getStoredHuntStreetsIds();
    if (storedHuntStreetsIds != null) {
      for (int id in storedHuntStreetsIds) {
        storage.removeKey(id.toString());
      }
    }
    storage.removeKey(huntStreetsIdsKey);
    // need to wait for this before writing it again
    await storage.removeKey(huntTimestampKey);
    return;
  }

  List<HuntingStreet> _updateFoundStatus(
      List<HuntingStreet> fetchedStreets, List<int>? storedHuntStreetsIds) {
    if (storedHuntStreetsIds != null) {
      return fetchedStreets.map(
        (street) {
          if (storedHuntStreetsIds.contains(street.id)) {
            return street.copyWith(
              found: true,
              foundDate: storage.getStringValue(street.id.toString()),
            );
          }
          return street;
        },
      ).toList();
    }

    return fetchedStreets;
  }
}

final huntingStreetProvider =
    StateNotifierProvider<HuntingStreetProvider, List<HuntingStreet>>(
        (ref) => HuntingStreetProvider());
