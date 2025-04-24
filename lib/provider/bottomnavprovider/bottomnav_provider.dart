import 'package:flutter/material.dart';

class BottomnavProvider extends ChangeNotifier {
  int _currentindex = 0;
  int get currentIndex => _currentindex;
  void changeIndex(int newIndex) {
    _currentindex = newIndex;
    notifyListeners();
  }
}
