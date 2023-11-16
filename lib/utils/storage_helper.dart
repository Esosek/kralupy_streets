import 'package:shared_preferences/shared_preferences.dart';

import 'package:kralupy_streets/utils/custom_logger.dart';

class StorageHelper {
  StorageHelper._privateConstructor() {
    _init();
  }
  static final StorageHelper _instance = StorageHelper._privateConstructor();

  factory StorageHelper() => _instance;

  late SharedPreferences _prefs;
  final log = CustomLogger('StorageHelper');
  bool _isInitialized = false;

  void _init() async {
    if (_isInitialized) {
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    log.trace('Successfully initialized');
    _isInitialized = true;
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
      log.trace('Removing $key');
      return;
    } catch (e) {
      log.warning('Failed to remove key $key: $e');
    }
  }

  void removeKeys(List<String> keys) {
    try {
      for (String key in keys) {
        removeKey(key);
      }
    } catch (e) {
      log.warning('Failed to remove keys $keys: $e');
    }
  }

  void setIntValue(String key, int value) => _setValue<int>(key, value);
  void setStringValue(String key, String value) =>
      _setValue<String>(key, value);
  void setListIntValue(String key, List<int> value) =>
      _setValue<List<int>>(key, value);
  void setBoolValue(String key, bool value) => _setValue<bool>(key, value);

  int? getIntValue(String key) => _getValue<int>(key);
  String? getStringValue(String key) => _getValue<String>(key);
  List<int>? getListIntValue(String key) => _getValue<List<int>>(key);
  bool? getBoolValue(String key) => _getValue<bool>(key);

  // Supported types: int, String, List<int>, bool
  void _setValue<T>(String key, T value) {
    try {
      if (value is int) {
        _prefs.setInt(key, value);
      } else if (value is String) {
        _prefs.setString(key, value);
      } else if (value is List<int>) {
        final stringList = value.map((v) => v.toString()).toList();
        _prefs.setStringList(key, stringList);
      } else if (value is bool) {
        _prefs.setBool(key, value);
      } else {
        log.error('Trying to setValue for unsupported data type');
      }
      log.trace('Storing $key: $value');
    } catch (e) {
      log.warning('Failed to set value for key $key: $e');
    }
  }

  // Supported types: int, String, List<int>, bool
  T? _getValue<T>(String key) {
    log.trace('Fetching $key value');
    try {
      if (T == int) {
        return _prefs.getInt(key) as T?;
      } else if (T == String) {
        return _prefs.getString(key) as T?;
      } else if (T == bool) {
        return _prefs.getBool(key) as T?;
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
        log.error('Trying to getValue for unsupported data type');
        return null;
      }
    } catch (e) {
      log.warning('Failed to get value for key $key: $e');
      return null;
    }
  }
}
