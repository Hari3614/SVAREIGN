import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/customer/user_model.dart';

class ProfileViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  /// Fetch user data from Firestore
  Future<void> fetchUserByUid(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(uid).get();
      print("Raw Firestore data: ${doc.data()}");

      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        print("User fetched: $_user");
        notifyListeners();
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print("Error fetching user by UID: $e");
    }
  }

  Future<void> updateName(String name) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("No user logged in");

      // Update Firebase Auth display name
      await currentUser.updateDisplayName(name);

      // Update Firestore 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'name': name});

      await fetchUserByUid(currentUser.uid);
      notifyListeners();
    } catch (e) {
      print("Error updating name: $e");
      throw Exception("Failed to update name");
    }
  }

  // Fetch current user data if logged in
  Future<void> fetchCurrentUser() async {
    User? currentuser;
    while (currentuser == null) {
      currentuser = FirebaseAuth.instance.currentUser;
      await Future.delayed(Duration(milliseconds: 100));
    }
    await fetchUserByUid(currentuser.uid);
  }

  void updateImageUrl(String newImageUrl) {
    if (_user != null) {
      _user = UserModel(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        phone: _user!.phone,
        imageurl: newImageUrl,
      );
      notifyListeners();
    }
  }
}
