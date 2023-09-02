import 'package:flutter/material.dart';

extension GetTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get themeColors => Theme.of(this).colorScheme;
}
