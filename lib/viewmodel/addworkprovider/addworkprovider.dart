import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/customer/addwork._model.dart';

class Workprovider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> addwork(Addworkmodel work) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No Authenticated User");
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('works')
        .add(work.tomap());
    notifyListeners();
  }
}
