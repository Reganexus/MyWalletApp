import 'package:shared_preferences/shared_preferences.dart';

class LayoutPreference {
  final String key;

  const LayoutPreference(this.key);

  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> save(bool isGrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, isGrid);
  }
}
