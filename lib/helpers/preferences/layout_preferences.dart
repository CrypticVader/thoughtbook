import 'package:shared_preferences/shared_preferences.dart';
import 'package:thoughtbook/constants/preferences.dart';

class LayoutPreferences {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  static void _initLayoutPreference() async {
    SharedPreferences prefs = await _prefs;
    if (prefs.getString(layoutPrefKey) == null) {
      await prefs.setString(layoutPrefKey, listLayoutPref);
    }
  }

  static Future<bool> setLayoutPreference(String value) async {
    final prefs = await _prefs;
    return prefs.setString(layoutPrefKey, value);
  }

  static Future<String> getLayoutPreference() async {
    final prefs = await _prefs;
    final currentLayout = prefs.getString(layoutPrefKey);
    if (currentLayout == null) {
      _initLayoutPreference();
    }
    return prefs.getString(layoutPrefKey)!;
  }

  static Future<bool> toggleLayoutPreference() async {
    final currentLayout = await getLayoutPreference();

    if (currentLayout == listLayoutPref) {
      final isLayoutToggled = await setLayoutPreference(gridLayoutPref);
      return isLayoutToggled;
    } else if (currentLayout == gridLayoutPref) {
      final isLayoutToggled = await setLayoutPreference(listLayoutPref);
      return isLayoutToggled;
    } else {
      return false;
    }
  }
}
