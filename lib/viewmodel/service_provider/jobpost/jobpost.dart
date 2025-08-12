import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/jobpost.dart';

class Jobpostprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Jobpost> _jobPost = [];
  List<Jobpost> get works => _jobPost;
  void startlisteningTojobs(String place) {
    _firebaseFirestore
        .collection('works')
        .where('place', isEqualTo: place)
        .where('status', isEqualTo: 'active')
        .orderBy('postedtime', descending: true)
        .snapshots()
        .listen((querySnapshots) {
          _jobPost =
              querySnapshots.docs
                  .map((doc) => Jobpost.fromfirestore(doc))
                  .toList();
          notifyListeners();
        });
  }
}
