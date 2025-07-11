import 'package:flutter/material.dart';

class Appstate with ChangeNotifier {
  void reloadapp() {
    notifyListeners();
  }
}
