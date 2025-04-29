import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:svareign/model/customer/user_model.dart';
import 'package:svareign/utils/phonenumbernormalise/normalise_phonenumber.dart';

class ProfileViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  /// Fetch user data from Firestore
  Future<void> fetchuser(String phone) async {
    try {
      final normalisedPhone = normalisephonenumber(phone);
      DocumentSnapshot doc =
          await _firestore.collection("users").doc(normalisedPhone).get();
      print("Raw Firestore data: ${doc.data()}");

      if (doc.exists) {
        _user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        print("User fetched: $_user");
        notifyListeners();
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  /// Upload image and update Firestore
  Future<void> updateProfileImage(String phoneNumber, File imageFile) async {
    try {
      final normalisedPhone = normalisephonenumber(phoneNumber);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$normalisedPhone.jpg');

      // Upload file
      await storageRef.putFile(imageFile);

      // Get URL
      final imageUrl = await storageRef.getDownloadURL();

      // Update Firestore document
      await _firestore.collection('users').doc(normalisedPhone).update({
        'imageUrl': imageUrl,
      });

      // Refresh local data
      await fetchuser(normalisedPhone);
    } catch (e) {
      print("Error updating profile image: $e");
    }
  }
}
