import 'package:flutter/cupertino.dart';

class PasswordVisiblityProvider with ChangeNotifier {
  bool _isobscuretext = true;
  bool get isobscured => _isobscuretext;
  void togglevisiblity() {
    _isobscuretext = !_isobscuretext;
    notifyListeners();
  }
}
