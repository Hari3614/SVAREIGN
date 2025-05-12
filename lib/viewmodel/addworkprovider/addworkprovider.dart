import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/customer/addwork._model.dart';

class Workprovider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //get users data
  Stream<List<Addworkmodel>> getworks() async* {
    // final user = _auth.currentUser;
    User? user;
    int retrycount = 0;
    while ((user = _auth.currentUser) == null && retrycount < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      retrycount++;
    }
    if (user == null) {
      yield [];
      return;
    }
    yield* _firestore
        .collection('users')
        .doc(user.uid)
        .collection('works')
        .orderBy('postedtime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((docs) => Addworkmodel.fromMap(docs.data()))
                  .toList(),
        );
  }

  // add users data
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
