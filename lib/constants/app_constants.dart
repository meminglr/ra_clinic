import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class AppConstants {
  static Color dropDownButtonsColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color sliverAppBarFlexColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
  final supabase = Supabase.instance.client;
}
