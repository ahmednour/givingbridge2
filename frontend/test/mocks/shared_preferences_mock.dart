import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences implements SharedPreferences {
  final Map<String, dynamic> _prefs = {};

  @override
  Set<String> getKeys() => _prefs.keys.toSet();

  @override
  Object? get(String key) => _prefs[key];

  @override
  bool? getBool(String key) => _prefs[key] as bool?;

  @override
  int? getInt(String key) => _prefs[key] as int?;

  @override
  double? getDouble(String key) => _prefs[key] as double?;

  @override
  String? getString(String key) => _prefs[key] as String?;

  @override
  List<String>? getStringList(String key) => _prefs[key] as List<String>?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _prefs[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _prefs[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _prefs[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _prefs[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _prefs[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _prefs.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _prefs.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  Future<bool> reload() async => true;

  @override
  bool containsKey(String key) => _prefs.containsKey(key);
}

// Mock SharedPreferences instance
SharedPreferences get mockSharedPreferences => MockSharedPreferences();
