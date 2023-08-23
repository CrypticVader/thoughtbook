enum LayoutPreference { list, grid }

extension LayoutSettingExtension on LayoutPreference {
  String get value => toString().split('.').last;
}
