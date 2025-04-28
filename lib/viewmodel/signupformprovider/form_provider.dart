import 'package:flutter/cupertino.dart';

class Signupformprovide extends ChangeNotifier {
  final Map<String, String> _fields = {
    "name": "",
    "email": "",
    "phone": "",
    "password": "",
    "confirmpassword": "",
  };
  bool get areAllFieldsFilled {
    return _fields.values.every((value) => value.isNotEmpty);
  }

  void updatefield(String key, String value) {
    _fields[key] = value;
    notifyListeners();
  }

  String getfields(String key) {
    return _fields[key] ?? "";
  }
}
