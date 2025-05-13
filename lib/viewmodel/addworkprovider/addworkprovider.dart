import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/customer/addwork._model.dart';

class Workprovider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream: Get works of current authenticated user
  Stream<List<Addworkmodel>> getworks() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        // No user is signed in
        return Stream.value([]);
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('works')
          .orderBy('postedtime', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Addworkmodel.fromMap(doc.data()))
                    .toList(),
          );
    });
  }

  // Add work for the current user
  Future<void> addwork(Addworkmodel work) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("No authenticated user found.");
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('works')
        .add(work.tomap());

    notifyListeners();
  }
}
