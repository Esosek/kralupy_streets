import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  StorageHelper() {
    _init();
  }
  late SharedPreferences _prefs;

  void _init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('StorageHelper: Initialized');
  }

  void addIntToList(String key, int value) {
    final list = _getValue<List<int>>(key);
    // Doesn't exist yet
    if (list == null) {
      _setValue<List<int>>(key, <int>[value]);
    }
    // Exists -> add and store
    else {
      if (!list.contains(value)) {
        final updatedList = [...list, value];
        _setValue(key, updatedList);
      }
    }
  }

  Future<void> removeKey(String key) async {
    try {
      await _prefs.remove(key);
      debugPrint('StorageHelper: Removing $key');
      return;
    } catch (e) {
      debugPrint('StorageHelper: Failed to remove key $key: $e');
    }
  }

  void removeKeys(List<String> keys) {
    try {
      for (String key in keys) {
        removeKey(key);
      }
    } catch (e) {
      debugPrint('StorageHelper: Failed to remove keys: $e');
    }
  }

  void setIntValue(String key, int value) => _setValue<int>(key, value);
  void setStringValue(String key, String value) =>
      _setValue<String>(key, value);
  void setListIntValue(String key, List<int> value) =>
      _setValue<List<int>>(key, value);

  int? getIntValue(String key) => _getValue<int>(key);
  String? getStringValue(String key) => _getValue<String>(key);
  List<int>? getListIntValue(String key) => _getValue<List<int>>(key);

  // Supported types: int, String, List<int>
  void _setValue<T>(String key, T value) {
    try {
      if (value is int) {
        _prefs.setInt(key, value);
      } else if (value is String) {
        _prefs.setString(key, value);
      } else if (value is List<int>) {
        final stringList = value.map((v) => v.toString()).toList();
        _prefs.setStringList(key, stringList);
      } else {
        throw Exception('StorageHelper: Unsupported data type.');
      }
      debugPrint('StorageHelper: Storing $key: $value');
    } catch (e) {
      debugPrint('StorageHelper: Failed to set value for key $key: $e');
    }
  }

  // Supported types: int, String, List<int>
  T? _getValue<T>(String key) {
    debugPrint('StorageHelper: Reading $key');
    try {
      if (T == int) {
        return _prefs.getInt(key) as T?;
      } else if (T == String) {
        return _prefs.getString(key) as T?;
      } else if (T == List<int>) {
        final stringList = _prefs.getStringList(key);
        if (stringList == null) {
          return null;
        }
        // Filters out non-int values
        final intList = stringList
            .map((str) => int.tryParse(str))
            .where((item) => item != null)
            .map((item) => item!)
            .toList();
        return intList as T?;
      } else {
        throw Exception('StorageHelper: Unsupported data type.');
      }
    } catch (e) {
      debugPrint('StorageHelper: Failed to get value for key $key: $e');
      return null;
    }
  }
}
