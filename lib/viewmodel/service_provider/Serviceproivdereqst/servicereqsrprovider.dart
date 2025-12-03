import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Servicereqsrprovider extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final Set<String> _requestedjobIds = {};
  Set<String> get requestedjobIds => _requestedjobIds;
  StreamSubscription<QuerySnapshot>? _requestsSubscription;

  void startListeningToRequests(String providerId) {
    // Cancel any existing subscription
    _requestsSubscription?.cancel();

    // Listen to requests in the global collection where this provider is involved
    _requestsSubscription = FirebaseFirestore.instance
        .collection('requests')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen(
          (snapshot) {
            _requestedjobIds.clear();
            for (var doc in snapshot.docs) {
              final jobId = doc['jobId'] as String;
              _requestedjobIds.add(jobId);
            }
            notifyListeners();
          },
          onError: (error) {
            debugPrint("Failed to listen to requests: $error");
          },
        );
  }

  void stopListeningToRequests() {
    _requestsSubscription?.cancel();
    _requestsSubscription = null;
  }

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
        print("already requested");
        _requestedjobIds.add(jobId);
        notifyListeners();
        return;
      }

      // Get provider profile data to include in the request
      final providerProfileSnapshot =
          await _firebaseFirestore
              .collection('services')
              .doc(providerId)
              .collection('profile')
              .limit(1)
              .get();

      String providerName = '';
      String providerImage = '';
      String providerPhone = '';

      if (providerProfileSnapshot.docs.isNotEmpty) {
        final profileData = providerProfileSnapshot.docs.first.data();
        providerName = profileData['fullname'] ?? profileData['name'] ?? '';
        providerImage =
            profileData['imageurl'] ?? profileData['imagepath'] ?? '';
        providerPhone = profileData['phone'] ?? '';
      }

      // Create the request data
      final requestdata = {
        'userId': userId,
        'providerId': providerId,
        'jobId': jobId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
        'providerName': providerName,
        'providerImage': providerImage,
        'providerPhone': providerPhone,
      };

      // Add to user's subcollection
      final docRef = await requestcollection.add(requestdata);

      try {
        // Also add to global requests collection for easier querying
        // Use the same document ID for consistency
        await _firebaseFirestore.collection('requests').doc(docRef.id).set({
          ...requestdata,
          'userDocPath': 'users/$userId',
          'requestDocId': docRef.id,
        });
      } catch (globalError) {
        // If adding to global collection fails, log the error but don't fail the whole operation
        debugPrint("Failed to add request to global collection: $globalError");
        // Show a user-friendly error message
        debugPrint(
          "Warning: Request was sent but may not appear in all views due to permissions.",
        );
      }

      print('request sent successfully');
      _requestedjobIds.add(jobId);
      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint("Firebase error sending request: ${e.message}");
      if (e.code == 'permission-denied') {
        debugPrint(
          "Permission denied error. Please check Firestore security rules.",
        );
      }
      rethrow; // Re-throw to let the UI handle it
    } catch (e) {
      debugPrint("Failed to send request: $e");
      rethrow; // Re-throw to let the UI handle it
    }
  }

  Future<void> fetchrequestedjobs(String providerId) async {
    try {
      _requestedjobIds.clear();

      // Query the global requests collection for requests from this provider
      final requestsSnapshot =
          await FirebaseFirestore.instance
              .collection('requests')
              .where('providerId', isEqualTo: providerId)
              .get();

      for (var doc in requestsSnapshot.docs) {
        final jobId = doc['jobId'] as String;
        _requestedjobIds.add(jobId);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch requested jobs: $e");
    }
  }

  // Utility method to synchronize existing requests to global collection
  Future<void> syncExistingRequestsToGlobal() async {
    try {
      print(
        "Starting synchronization of existing requests to global collection",
      );

      // Get all users
      final usersSnapshot = await _firebaseFirestore.collection('users').get();

      int syncedCount = 0;

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final requestsSnapshot =
            await _firebaseFirestore
                .collection('users')
                .doc(userId)
                .collection('requests')
                .get();

        for (var requestDoc in requestsSnapshot.docs) {
          final requestId = requestDoc.id;
          final requestData = requestDoc.data();

          // Check if this request already exists in global collection
          final globalRequestDoc =
              await _firebaseFirestore
                  .collection('requests')
                  .doc(requestId)
                  .get();

          if (!globalRequestDoc.exists) {
            // Add to global collection if it doesn't exist
            await _firebaseFirestore.collection('requests').doc(requestId).set({
              ...requestData,
              'userDocPath': 'users/$userId',
              'requestDocId': requestId,
            });

            syncedCount++;
            print("Synced request $requestId to global collection");
          }
        }
      }

      print(
        "Finished synchronization. Synced $syncedCount requests to global collection",
      );
    } catch (e) {
      debugPrint("Failed to sync existing requests: $e");
    }
  }
}
