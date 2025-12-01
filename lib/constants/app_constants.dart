import 'package:flutter/material.dart';

abstract final class AppConstants {
  static Color dropDownButtonsColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color sliverAppBarFlexColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
}
