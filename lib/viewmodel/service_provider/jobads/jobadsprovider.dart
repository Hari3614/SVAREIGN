import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/serviceprovider/jobsadsmodel.dart';

class Jobadsprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Jobsadsmodel> _globalposts = [];
  List<Jobsadsmodel> get globalposts => _globalposts;
  bool isloading = false;
  bool get loading => isloading;
  Future<void> fetchglobalposts(String place) async {
    isloading = true;
    notifyListeners();
    try {
      final snapshot =
          await _firebaseFirestore
              .collection('posts')
              .where('place', isEqualTo: place)
              .orderBy('postedtime', descending: true)
              .get();
      _globalposts =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return Jobsadsmodel.fromMap(data);
          }).toList();
    } catch (e) {
      debugPrint("error fetching global posts :$e");
    }
    isloading = false;
    notifyListeners();
  }

  Future<void> addpost(Jobsadsmodel post) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No authenticated User found");
    }
    final postmap = post.tomap();
    try {
      final providerdoc =
          await _firebaseFirestore.collection('services').doc(user.uid).get();
      final place = providerdoc.data()?['place'] ?? 'unknknown';
      await _firebaseFirestore
          .collection('services')
          .doc(user.uid)
          .collection('posts')
          .add(postmap);
      await _firebaseFirestore.collection('posts').add({
        ...postmap,
        'providerId': user.uid,
        'phonenumber': user.phoneNumber,
        'place': place,
      });
      print("post added successfully");

      notifyListeners();
    } catch (e) {
      debugPrint('error adding post with place :$e');
    }
  }
}
