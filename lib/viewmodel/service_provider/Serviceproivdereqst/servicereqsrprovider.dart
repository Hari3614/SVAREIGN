import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Servicereqsrprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final Set<String> _requestedjobIds = {};
  Set<String> get requestedjobIds => _requestedjobIds;
  Future<void> sendreqstuser({
    required String userId,
    required String providerId,
    required String jobId,
  }) async {
    try {
      final requestcollection = _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('requests');
      final existingreqst =
          await requestcollection
              .where('providerId', isEqualTo: providerId)
              .where('jobId', isEqualTo: jobId)
              .get();

      if (existingreqst.docs.isNotEmpty) {
        print("allready reqsted");
        _requestedjobIds.add(jobId);
        notifyListeners();
        return;
      }
      final requestdata = {
        'userId': userId,
        'providerId': providerId,
        'jobId': jobId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
      };
      await requestcollection.add(requestdata);
      print('reqsted sent successfully');
      _requestedjobIds.add(jobId);
      notifyListeners();
    } catch (e) {
      debugPrint(" Failed to send request: $e");
    }
  }

  Future<void> fetchrequestedjobs(String providerId) async {
    try {
      _requestedjobIds.clear();
      final querySnapshot =
          await _firebaseFirestore
              .collection('requests')
              .where('providerId', isEqualTo: providerId)
              .get();
      for (var doc in querySnapshot.docs) {
        final jobId = doc['jobId'] as String;
        _requestedjobIds.add(jobId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch requested jobs: $e");
    }
  }
}
