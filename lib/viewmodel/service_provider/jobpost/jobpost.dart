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
          final now = DateTime.now();
          _jobPost = querySnapshots.docs
              .map((doc) => Jobpost.fromfirestore(doc))
              .where((job) {
                final expiry = job.postedtime.add(const Duration(hours: 24));
                return expiry.isAfter(now);
              })
              .toList();
          notifyListeners();
        });
  }
}
