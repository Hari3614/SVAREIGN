import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/serviceprovider/jobsadsmodel.dart';
import 'package:svareign/utils/calculatedistance/calculatedistance.dart';

class Jobadsprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Jobsadsmodel> _globalposts = [];
  List<Jobsadsmodel> get globalposts => _globalposts;
  bool isloading = false;
  bool get loading => isloading;
  Future<void> fetchglobalposts({
    required double userLat,
    required double userLng,
    double radiusinKm = 20,
  }) async {
    isloading = true;
    notifyListeners();
    try {
      final snapshot =
          await _firebaseFirestore
              .collection('posts')
              .orderBy('postedtime', descending: true)
              .get();

      final now = DateTime.now();
      _globalposts =
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

      _globalposts.shuffle();
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
      final place = providerdoc.data()?['place'] ?? 'unknown';
      final providerLocation = providerdoc.data()?['location'];
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
        if (providerLocation != null) 'location': providerLocation,
      });
      print("post added successfully");
      if (providerLocation != null) {
        await fetchglobalposts(
          userLat: (providerLocation['latitude'] as num).toDouble(),
          userLng: (providerLocation['longitude'] as num).toDouble(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('error adding post with place :$e');
    }
  }

  Future<void> deletePost(String postId, String providerId) async {
    try {
      // Delete from global posts collection
      await _firebaseFirestore.collection('posts').doc(postId).delete();

      // Delete from provider's posts collection
      await _firebaseFirestore
          .collection('services')
          .doc(providerId)
          .collection('posts')
          .doc(postId)
          .delete();

      // Remove from local list
      _globalposts.removeWhere((post) => post.id == postId);
      notifyListeners();

      print("post deleted successfully");
    } catch (e) {
      debugPrint('error deleting post: $e');
      rethrow;
    }
  }
}
