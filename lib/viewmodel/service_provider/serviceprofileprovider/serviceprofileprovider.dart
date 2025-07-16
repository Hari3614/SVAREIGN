import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/serviceprovider/setup_profilemodel.dart';

class Serviceprofileprovider with ChangeNotifier {
  Profile? profile;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    final serviceProviderId = FirebaseAuth.instance.currentUser?.uid;
    if (serviceProviderId == null) {
      print("No user logged in");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(serviceProviderId)
              .collection('profile')
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        profile = Profile.frommap(snapshot.docs.first.data());
        print("Fetched profile: ${snapshot.docs.first.data()}");
      } else {
        print("No profile document found for this user.");
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
