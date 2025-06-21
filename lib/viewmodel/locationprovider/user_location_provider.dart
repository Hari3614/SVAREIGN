import 'package:flutter/cupertino.dart';
import 'package:svareign/services/location_services/fetchinguseraddress/fetching_address.dart';

class UserLocationProvider extends ChangeNotifier {
  String? _address;
  String? get address => _address;
  Future<void> updateaddress() async {
    try {
      final userservice = Userservice();
      final fetchedaddress = await userservice.getuseraddress();
      _address = fetchedaddress;
      notifyListeners();
    } catch (e) {
      print("error updating address :$e");
    }
  }
}
