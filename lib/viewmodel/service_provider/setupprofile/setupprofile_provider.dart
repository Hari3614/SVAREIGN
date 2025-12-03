import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/setup_profilemodel.dart';

class Profileprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  Profile? _profile;
  String? _phoneNumber;
  String? _email;

  Profile? get profile => _profile;
  String? get phoneNumber => _phoneNumber;
  String? get email => _email;

  Future<void> addprofile(Profile profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No authenticated user");

    await _firebaseFirestore
        .collection('services')
        .doc(uid)
        .collection('profile')
        .doc('main')
        .set(profile.tomap());

    _profile = profile;
    notifyListeners();
  }

  Future<void> fetchprofile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No authenticated user");

    // Fetch profile data
    final profileSnapshot =
        await _firebaseFirestore
            .collection('services')
            .doc(uid)
            .collection('profile')
            .limit(1)
            .get();

    if (profileSnapshot.docs.isNotEmpty) {
      final data = profileSnapshot.docs.first.data();
      _profile = Profile.frommap(data);
    } else {
      _profile = null;
    }

    // Fetch phone number and email from main service document
    final serviceSnapshot =
        await _firebaseFirestore.collection('services').doc(uid).get();

    if (serviceSnapshot.exists) {
      final serviceData = serviceSnapshot.data() as Map<String, dynamic>;
      _phoneNumber = serviceData['phone'] as String?;
      _email = serviceData['email'] as String?;
    }

    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String upiId,
    required String payment,
    String? phoneNumber,
    String? email,
    String? imageUrl,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No authenticated user");

    // Update profile subcollection
    final profileDocRef = _firebaseFirestore
        .collection('services')
        .doc(uid)
        .collection('profile')
        .doc('main');

    final profileData = {
      "fullname": name,
      "upiId": upiId,
      "payment": payment,
      if (imageUrl != null) "imageurl": imageUrl,
    };

    await profileDocRef.set(profileData, SetOptions(merge: true));

    // Update main service document with phone and email
    final serviceDocRef = _firebaseFirestore.collection('services').doc(uid);

    final serviceData = <String, dynamic>{};
    if (phoneNumber != null) {
      serviceData['phone'] = phoneNumber;
      _phoneNumber = phoneNumber;
    }
    if (email != null) {
      serviceData['email'] = email;
      _email = email;
    }

    if (serviceData.isNotEmpty) {
      await serviceDocRef.set(serviceData, SetOptions(merge: true));
    }

    // update local profile object
    if (_profile != null) {
      _profile = Profile(
        fullname: name,
        upiId: upiId,
        payment: payment,
        imageurl: imageUrl,
      );
    }

    notifyListeners();
  }

  Future<String> uploadProfileImage(File file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No authenticated user");

    try {
      if (!file.existsSync()) {
        throw Exception("File does not exist: ${file.path}");
      }

      final ref = _storage.ref().child("profile_images/$uid/profile.jpg");

      await ref.putFile(file); // upload

      final downloadUrl = await ref.getDownloadURL(); // get link
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Firebase Storage error: ${e.code} - ${e.message}");
      throw Exception("Upload failed: ${e.message}");
    } catch (e) {
      print("General error: $e");
      throw Exception("Upload failed: $e");
    }
  }
}
