import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Addworkmodel.fromMap(doc.data(), doc.id))
                    .toList(),
          );
    });
  }

  /// Add a new work (active)
  Future<void> addwork(Addworkmodel work) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated user found");
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userplace = userDoc.data()?['place'];
    if (userplace == null) {
      throw Exception('User place is not available in profile');
    }

    final workmap = {
      ...work.tomap(),
      'place': userplace,
      'userId': user.uid,
      "userphone": user.phoneNumber,
      'status': 'active', // ✅ added for filtering
    };

    // Add to global active works
    final globaldoc = await _firestore.collection('works').add(workmap);

    // Add to user's active works
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('works')
        .doc(globaldoc.id)
        .set({...work.tomap(), 'place': userplace, 'status': 'active'});
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
