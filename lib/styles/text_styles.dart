import 'package:flutter/material.dart';

class CustomTextStyle {
  late final BuildContext context;

  CustomTextStyle(this.context);

  late TextStyle appBarTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onBackground.withAlpha(210),
  );
}
