import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Jobstatprovider with ChangeNotifier {
  int jobtodaycount = 0;
  int completedjobcount = 0;
  bool isloading = true;
  Future<void> fetchjobstats() async {
    final providerId = FirebaseAuth.instance.currentUser?.uid;
    if (providerId == null) return;
    final now = DateTime.now();
    final startOfday = DateTime(now.year, now.month, now.day);
    final endofday = startOfday.add(const Duration(days: 1));
    try {
      final todaysnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('requests')
              .where('providerId', isEqualTo: providerId)
              .where('status', isEqualTo: 'Accepted')
              .where('timestamp', isGreaterThanOrEqualTo: startOfday)
              .where('timestamp', isLessThan: endofday)
              .get();
      final completedsnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('requests')
              .where('providerId', isEqualTo: providerId)
              .where('status', isEqualTo: "Completed")
              .where('timestamp', isGreaterThanOrEqualTo: startOfday)
              .where('timestamp', isLessThan: endofday)
              .get();

      jobtodaycount = todaysnapshot.docs.length;
      completedjobcount = completedsnapshot.docs.length;
      print("jobtodaycount :$jobtodaycount");
      print("completedcount:$completedjobcount");
      isloading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fecthing counts");
    }
  }
}
