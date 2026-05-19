import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:svareign/model/serviceprovider/jobsadsmodel.dart';
import 'package:svareign/utils/calculatedistance/calculatedistance.dart';

class ServicePostProvider with ChangeNotifier {
  List<Jobsadsmodel> _servicePosts = [];
  bool _isLoading = false;

  List<Jobsadsmodel> get servicePosts => _servicePosts;
  bool get isLoading => _isLoading;

  Future<void> fetchServicePosts({
    required double userLat,
    required double userLng,
    double radiusinKm = 20,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('posts')
              .orderBy('postedtime', descending: true)
              .get();

      final now = DateTime.now();
      _servicePosts =
          snapshot.docs
              .where((doc) {
                final data = doc.data();
                // Filter expired posts
                if (data['expirytime'] != null) {
                  final expiryTime = (data['expirytime'] as Timestamp).toDate();
                  if (!expiryTime.isAfter(now)) return false;
                }
                // Filter by radius if location available
                final location = data['location'];
                if (location != null &&
                    location['latitude'] != null &&
                    location['longitude'] != null) {
                  final distance = calculateDistance(
                    userLat,
                    userLng,
                    (location['latitude'] as num).toDouble(),
                    (location['longitude'] as num).toDouble(),
                  );
                  return distance <= radiusinKm;
                }
                // Include old posts without location (fallback)
                return true;
              })
              .map((doc) {
                final data = doc.data();
                return Jobsadsmodel.fromMap(doc.id, data);
              })
              .toList();

      _servicePosts.shuffle();
    } catch (e) {
      debugPrint("Error fetching service posts: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
