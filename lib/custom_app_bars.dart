import 'package:flutter/material.dart';

class CustomAppbars {
  static PreferredSizeWidget? buildAppBar(int index) {
    switch (index) {
      case 0:
        return costumersAppbar();
      case 1:
        return null;
      default:
        return AppBar(title: Text("Profil"));
    }
  }

  static PreferredSizeWidget costumersAppbar() {
    return AppBar(title: Text("Müşteriler"), actions: [Icon(Icons.search)]);
  }
}
