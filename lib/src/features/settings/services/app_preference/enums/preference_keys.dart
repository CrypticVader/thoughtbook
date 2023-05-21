enum PreferenceKey {
  layout,
  isGuest,
  lastSyncedWithCloud,
}

extension SettingsKeysExtension on PreferenceKey {
  String get value => toString().split('.').last;
}
