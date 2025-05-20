import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Servicereqsrprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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
      print('reqsted sentence successfully');
    } catch (e) {
      debugPrint(" Failed to send request: $e");
    }
  }
}
