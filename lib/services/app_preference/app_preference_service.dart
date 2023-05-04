import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thoughtbook/services/app_preference/enums/preference_keys.dart';
import 'package:thoughtbook/services/app_preference/enums/preference_values.dart';

/// This service is used to access and modify the app's preference values.
///
/// Uses the shared_preferences plugin.
class AppPreferenceService {
  late SharedPreferences _prefs;

  void initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _initAllPreferences();
  }

  static final _shared = AppPreferenceService._sharedInstance();

  AppPreferenceService._sharedInstance() {
    initPrefs();
  }

  factory AppPreferenceService() => _shared;

  /// Responsible for initializing all preference keys with a default value if one is not present.
  void _initAllPreferences() async {
    // init layout preference
    final layoutPref = _prefs.getString(PreferenceKey.selectedLayout.value);
    if (layoutPref == null) {
      final couldSet = await _prefs.setString(
        PreferenceKey.selectedLayout.value,
        LayoutPreference.list.value,
      );
      if (!couldSet) {
        throw CouldNotSetPreferenceException();
      }
    }

    // init user-logged-in-as-guest key
    final isUserGuest = _prefs.getBool(PreferenceKey.isGuest.value);
    if (isUserGuest == null) {
      await _prefs.setBool(PreferenceKey.isGuest.value, false);
    }
  }

  /// Whether the the current user has proceeded to use the app as a guest
  /// without logging in with an account.
  bool get isUserLoggedInAsGuest {
    _initAllPreferences();
    final isUserGuest = _prefs.getBool(PreferenceKey.isGuest.value);
    if (isUserGuest == null) {
      throw CouldNotGetPreferenceException();
    }
    return isUserGuest;
  }

  /// Sets the given preference key with the value provided.
  ///
  /// The value can be of type dynamic and is set appropriately by this function.
  void setPreference({
    required PreferenceKey key,
    required dynamic value,
  }) async {
    if (key == PreferenceKey.lastSyncedWithCloud) {
      value = (value as DateTime).toIso8601String();
    }
    if (value is String) {
      final couldSet = await _prefs.setString(key.value, value);
      if (!couldSet) {
        throw CouldNotSetPreferenceException();
      }
    } else if (value is bool) {
      final couldSet = await _prefs.setBool(key.value, value);
      if (!couldSet) {
        throw CouldNotSetPreferenceException();
      }
    } else {
      throw CouldNotSetPreferenceException();
    }
  }

  /// Gets the preference value for the given key if it's value is not null.
  dynamic getPreference(PreferenceKey key) {
    try {
      final value = _prefs.get(key.value);
      log(value.toString());
      if (value == null) {
        throw PreferenceNotInitializedException();
      } else {
        if (key == PreferenceKey.lastSyncedWithCloud) {
          return DateTime.parse(value as String);
        }
        return value;
      }
    } catch (e) {
      throw CouldNotGetPreferenceException();
    }
  }
}

class CouldNotGetPreferenceException implements Exception {}

class CouldNotSetPreferenceException implements Exception {}

class PreferenceNotInitializedException implements Exception {}
