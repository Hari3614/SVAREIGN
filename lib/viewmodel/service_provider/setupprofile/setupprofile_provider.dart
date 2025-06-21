import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/setup_profilemodel.dart';

class Profileprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Profile? _profile;

  Profile? get profile => _profile;

  Future<void> addprofile(Profile profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No authenticated user");

    await _firebaseFirestore
        .collection('services')
        .doc(uid)
        .collection('profile')
        .add(profile.tomap());

    _profile = profile;
    notifyListeners();
  }

  Future<void> fetchprofile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No authenticated user");

    final snapshot =
        await _firebaseFirestore
            .collection('services')
            .doc(uid)
            .collection('profile')
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      _profile = Profile.frommap(data);
    } else {
      _profile = null;
    }

    notifyListeners();
  }
}
