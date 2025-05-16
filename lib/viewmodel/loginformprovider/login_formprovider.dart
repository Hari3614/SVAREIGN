import 'package:flutter/cupertino.dart';

class LoginFormprovider extends ChangeNotifier {
  final Map<String, String> _fields = {"email": "", "password": ""};
  bool get areallfiedlfilled {
    return _fields.values.every((value) => value.isNotEmpty);
  }

  void updatefields(String key, String value) {
    _fields[key] = value;
    notifyListeners();
  }

  String getfield(String key) {
    return _fields[key] ?? "";
  }

  void clearFields() {
    _fields.updateAll((key, value) => '');
    notifyListeners();
  }
}
