import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/customer/reviewmodel.dart';

class Reviewprovider with ChangeNotifier {
  List<Reviewmodel> _reviews = [];
  List<Reviewmodel> get reviews => _reviews;
  Future<void> fetchreviews(String providerId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(providerId)
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .get();
      _reviews =
          snapshot.docs
              .map((doc) => Reviewmodel.frommap(doc.data(), doc.id))
              .toList();
      notifyListeners();
    } catch (e) {}
  }

  Future<void> addreview({
    required String providerId,
    required String jobId,
    required String reviewtext,
    required double rating,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }
      final review = Reviewmodel(
        id: '',
        jobId: jobId,
        providerId: providerId,
        rating: rating,
        review: reviewtext,
        userid: user.uid,
        timestamp: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('services')
          .doc(providerId)
          .collection('reviews')
          .add(review.tomap());
      print("Review added successfully");
    } catch (e) {
      print("Error adding review: $e");
    }
  }
}
