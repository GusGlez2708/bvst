import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _keyLevel = 'saved_level';

  /// Returns the saved level. Defaults to 1 if no level is saved.
  Future<int> getSavedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLevel) ?? 1;
  }

  /// Saves the specified level.
  Future<void> saveLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLevel, level);
  }
}
