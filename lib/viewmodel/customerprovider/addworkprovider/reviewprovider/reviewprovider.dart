import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/customer/reviewmodel.dart';

class ReviewProvider with ChangeNotifier {
  List<Reviewmodel> _reviews = [];
  List<Reviewmodel> get reviews => _reviews;

  Future<void> fetchReviews(String providerId) async {
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
    } catch (e) {
      print("Error fetching reviews: $e");
    }
  }

  Future<int> getreviews(String providerId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('reviews')
            .where('providerId', isEqualTo: providerId)
            .get();
    return snapshot.docs.length;
  }

  Future<void> addReview({
    required String providerId,
    required String jobId,
    required String reviewText,
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
        review: reviewText,
        userid: user.uid,
        timestamp: DateTime.now(),
      );

      final globalRef = await FirebaseFirestore.instance
          .collection('reviews')
          .add(review.tomap());
      await globalRef.update({'id': globalRef.id});

      final subRef = FirebaseFirestore.instance
          .collection('services')
          .doc(providerId)
          .collection('reviews')
          .doc(globalRef.id);
      await subRef.set(review.tomap());

      await _updateProviderRating(providerId);

      print("Review added successfully");
    } catch (e) {
      print("Error adding review: $e");
    }
  }

  Future<void> _updateProviderRating(String providerId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('services')
            .doc(providerId)
            .collection('reviews')
            .get();

    if (snapshot.docs.isEmpty) return;

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['rating'] ?? 0).toDouble();
    }
    double avgRating = total / snapshot.docs.length;

    await FirebaseFirestore.instance
        .collection('services')
        .doc(providerId)
        .update({'avgRating': avgRating});
  }

  Future<List<Map<String, dynamic>>> getBestProvidersInDistrict(
    String district,
  ) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .where('district', isEqualTo: district)
              .orderBy('avgRating', descending: true)
              .limit(5)
              .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching best providers: $e");
      return [];
    }
  }

  Future<double> getAverageRating(String providerId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("reviews")
            .where("providerId", isEqualTo: providerId)
            .get();

    if (snapshot.docs.isEmpty) return 0.0;

    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc['rating'] ?? 0).toDouble();
    }
    return total / snapshot.docs.length;
  }
}
