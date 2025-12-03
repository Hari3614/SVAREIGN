import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:svareign/model/serviceprovider/jobsadsmodel.dart';

class ServicePostProvider with ChangeNotifier {
  List<Jobsadsmodel> _servicePosts = [];
  bool _isLoading = false;

  List<Jobsadsmodel> get servicePosts => _servicePosts;
  bool get isLoading => _isLoading;

  Future<void> fetchServicePosts(String place) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .where('place', isEqualTo: place)
              .orderBy('postedtime', descending: true)
              .get();

      final now = DateTime.now();
      _servicePosts =
          snapshot.docs
              .where((doc) {
                final data = doc.data();
                final expiryTime = (data['expirytime'] as Timestamp).toDate();
                return expiryTime.isAfter(now);
              })
              .map((doc) {
                final data = doc.data();
                return Jobsadsmodel.fromMap(doc.id, data);
              })
              .toList();

      // Shuffle the posts
      _servicePosts.shuffle();
    } catch (e) {
      debugPrint("Error fetching service posts: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
