import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:svareign/model/customer/addwork._model.dart';

class Workprovider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get active works for current authenticated user
  Stream<List<Addworkmodel>> getworks() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('works')
          .orderBy('postedtime', descending: true)
          .snapshots()
          .map((snapshot) {
            final now = DateTime.now();
            return snapshot.docs
                .map((doc) => Addworkmodel.fromMap(doc.data(), doc.id))
                .where((work) => work.expirytime.isAfter(now))
                .toList();
          });
    });
  }

  /// Add a new work (active)
  Future<void> addwork(Addworkmodel work) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user found");
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    String? userplace = userDoc.data()?['place'];
    final userLocation = userDoc.data()?['location'];

    // If place is not set, compute it from location coordinates
    if (userplace == null && userLocation != null) {
      try {
        final lat = userLocation['latitude'];
        final lng = userLocation['longitude'];
        if (lat != null && lng != null) {
          final placemarks = await placemarkFromCoordinates(lat, lng);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            userplace = '${p.locality},${p.administrativeArea}';
            // Save place to user doc for future use
            await _firestore.collection('users').doc(user.uid).set({
              'place': userplace,
            }, SetOptions(merge: true));
          }
        }
      } catch (e) {
        debugPrint('Error computing place from location: $e');
      }
    }

    final workmap = {
      ...work.tomap(),
      if (userplace != null) 'place': userplace,
      'userId': user.uid,
      "userphone": user.phoneNumber,
      'status': 'active',
      if (userLocation != null) 'location': userLocation,
    };

    // Add to global active works
    final globaldoc = await _firestore.collection('works').add(workmap);

    // Add to user's active works
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('works')
        .doc(globaldoc.id)
        .set({
          ...work.tomap(),
          if (userplace != null) 'place': userplace,
          'status': 'active',
          if (userLocation != null) 'location': userLocation,
        });
  }

  Future<void> deletework(String workId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Delete from user's active works
    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("works")
        .doc(workId)
        .delete();

    // Delete from global active works
    await _firestore.collection("works").doc(workId).delete();
  }
}
