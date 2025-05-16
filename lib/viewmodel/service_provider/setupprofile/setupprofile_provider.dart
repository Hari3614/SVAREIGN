import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/setup_profilemodel.dart';

class Profileprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> addprofile(Profile profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("No authenticated user");
    }
    await _firebaseFirestore
        .collection('services')
        .doc(uid)
        .collection('profile')
        .add(profile.tomap());
    notifyListeners();
  }
}
