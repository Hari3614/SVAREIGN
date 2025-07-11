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
        .orderBy('postedtime', descending: true)
        .snapshots()
        .listen((quersnapshots) {
          _jobPost =
              quersnapshots.docs
                  .map((doc) => Jobpost.fromfirestore(doc))
                  .toList();
          notifyListeners();
        });
  }
}
