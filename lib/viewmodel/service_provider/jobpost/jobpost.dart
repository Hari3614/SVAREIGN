import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/jobpost.dart';
import 'package:svareign/utils/calculatedistance/calculatedistance.dart';

class Jobpostprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Jobpost> _jobPost = [];
  List<Jobpost> get works => _jobPost;
  void startlisteningTojobs({
    required double providerLat,
    required double providerLng,
    double radiusinKm = 20,
  }) {
    _firebaseFirestore
        .collection('works')
        .where('status', isEqualTo: 'active')
        .orderBy('postedtime', descending: true)
        .snapshots()
        .listen((querySnapshots) {
          final now = DateTime.now();
          _jobPost =
              querySnapshots.docs
                  .where((doc) {
                    final data = doc.data();
                    // Filter by expiry
                    final expiry =
                        data['expirytime'] != null
                            ? (data['expirytime'] as Timestamp).toDate()
                            : (data['postedtime'] as Timestamp).toDate().add(
                              const Duration(hours: 24),
                            );
                    if (!expiry.isAfter(now)) return false;

                    // Filter by radius if location available
                    final location = data['location'];
                    if (location != null &&
                        location['latitude'] != null &&
                        location['longitude'] != null) {
                      final distance = calculateDistance(
                        providerLat,
                        providerLng,
                        (location['latitude'] as num).toDouble(),
                        (location['longitude'] as num).toDouble(),
                      );
                      return distance <= radiusinKm;
                    }
                    // Include old posts without location (fallback)
                    return true;
                  })
                  .map((doc) => Jobpost.fromfirestore(doc))
                  .toList();
          notifyListeners();
        });
  }
}
