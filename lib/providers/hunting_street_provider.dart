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
      final currentHunting = await getCurrentHunting();
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
          publicFinder: street.publicFinder ?? username,
        );
      }
      return street;
    }).toList();

    state = updatedHunt;

    storage.setStringValue(streetId.toString(), formattedDate);
    storage.addIntToList(huntStreetsIdsKey, streetId);
  }

  Future<Map<String, dynamic>> getCurrentHunting() async {
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
        return huntDocs[0].data();
      } else {
        log.warning('No active hunting found');
        return {};
      }
    } catch (e) {
      log.error('Failed to fetch active hunting: $e');
      return {};
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
