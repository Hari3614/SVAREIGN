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

  Future<bool> hasUserReviewedJob({
    required String providerId,
    required String jobId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('reviews')
            .where('providerId', isEqualTo: providerId)
            .where('jobId', isEqualTo: jobId)
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<bool> addReview({
    required String providerId,
    required String jobId,
    required String reviewText,
    required double rating,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in");
        return false;
      }

      // Check if user already reviewed this job
      final alreadyReviewed = await hasUserReviewedJob(
        providerId: providerId,
        jobId: jobId,
      );
      if (alreadyReviewed) {
        return false;
      }

      final firestore = FirebaseFirestore.instance;

      // 🔹 Fetch provider profile from services/{providerId}/profile
      final profileSnapshot =
          await firestore
              .collection('services')
              .doc(providerId)
              .collection('profile')
              .limit(1)
              .get();

      if (profileSnapshot.docs.isEmpty) {
        print("Provider profile not found");
        return false;
      }

      final profileData = profileSnapshot.docs.first.data();
      final providerName = profileData['fullname'] ?? "Unknown";
      final hourlyPayment = profileData['payment'] ?? 0;
      final categories = profileData['categories'] ?? [];
      final imageurl = profileData['imageurl'] ?? "";

      final review = {
        'id': user.uid,
        'jobId': jobId,
        'providerId': providerId,
        'rating': rating,
        'review': reviewText,
        'userId': user.uid,
        'timestamp': DateTime.now(),
        // 🔹 Add extra provider info
        'providerName': providerName,
        'hourlyPayment': hourlyPayment,
        'categories': categories,
        'imageurl': imageurl,
      };

      // Save review in global collection
      final globalRef = await firestore.collection('reviews').add(review);
      await globalRef.update({'id': globalRef.id});

      // Save review in provider subcollection
      final subRef = firestore
          .collection('services')
          .doc(providerId)
          .collection('reviews')
          .doc(globalRef.id);
      await subRef.set(review);

      // Update avg rating
      await _updateProviderRating(providerId);

      return true;
    } catch (e) {
      print("Error adding review: $e");
      return false;
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
        .update({'avgRating': avgRating, 'reviewcount': snapshot.docs.length});
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

  Future<List<Map<String, dynamic>>> fetchBestProvidersByLocation(
    String place,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final providerSnapshot =
          await firestore
              .collection('services')
              .where('place', isEqualTo: place)
              .get();

      if (providerSnapshot.docs.isEmpty) return [];

      List<Map<String, dynamic>> result = [];

      for (var provider in providerSnapshot.docs) {
        final providerId = provider.id;

        // 🔹 Fetch profile from subcollection
        final profileSnapshot =
            await firestore
                .collection('services')
                .doc(providerId)
                .collection('profile')
                .limit(1)
                .get();

        String imageurl = "";
        List categories = [];
        String fullname = "";

        if (profileSnapshot.docs.isNotEmpty) {
          final profileData = profileSnapshot.docs.first.data();
          imageurl = profileData['imageurl'] ?? "";
          categories = profileData['categories'] ?? [];
          fullname = profileData['fullname'] ?? "";
        }

        // 🔹 Fetch reviews for this provider
        final reviewsSnapshot =
            await firestore
                .collection('reviews')
                .where('providerId', isEqualTo: providerId)
                .get();

        final ratings =
            reviewsSnapshot.docs
                .map((doc) => (doc['rating'] ?? 0).toDouble())
                .toList();

        final avgRating =
            ratings.isEmpty
                ? 0.0
                : ratings.reduce((a, b) => a + b) / ratings.length;

        result.add({
          'providerId': providerId,
          'name': provider['name'] ?? 'Unknown',
          'fullname': fullname,
          'place': provider['place'] ?? '',
          'avgRating': avgRating,
          'reviewCount': ratings.length,
          'imageurl': imageurl,
          'categories': categories,
        });

        print("Provider data: ${provider.data()}");
      }

      result.sort((a, b) => (b['avgRating']).compareTo(a['avgRating']));
      return result;
    } catch (e) {
      print("Error fetching best providers: $e");
      return [];
    }
  }
}
