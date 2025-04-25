import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/customer/user_model.dart';

class ProfileViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  Future<void> fetchuser(String phone) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(phone).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        print("User fetched: $_user");

        notifyListeners();
        //   return true;
      } else {
        print('user document doesnt exitts');
      }
    } catch (e) {
      print("error fectch $e");
    }
    // return false;
  }
}
