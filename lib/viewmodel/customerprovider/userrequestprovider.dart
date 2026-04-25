import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/reqstmodel.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/addworkprovider.dart';
import 'package:svareign/services/notification/notification_service.dart';
import 'dart:async';

class Userrequestprovider extends ChangeNotifier {
  List<Reqstmodel> _requests = [];
  List<Reqstmodel> get request => _requests;
  StreamSubscription<QuerySnapshot>? _requestsSubscription;

  //fetch profile
  Future<Map<String, dynamic>?> fetchproviderProfile(String providerId) async {
    try {
      // First fetch the profile data from the profile subcollection
      final profilesnapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(providerId)
              .collection('profile')
              .limit(1)
              .get();

      // Then fetch the phone number from the main service document
      final serviceSnapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(providerId)
              .get();

      Map<String, dynamic> combinedData = {};

      // Add profile data if it exists
      if (profilesnapshot.docs.isNotEmpty) {
        combinedData.addAll(profilesnapshot.docs.first.data());
      }

      // Add phone number from main service document if it exists
      if (serviceSnapshot.exists) {
        final serviceData = serviceSnapshot.data() as Map<String, dynamic>;
        if (serviceData.containsKey('phone')) {
          combinedData['phone'] = serviceData['phone'];
        }
      }

      return combinedData.isEmpty ? null : combinedData;
    } catch (e) {
      debugPrint("error fetching provider profile: $e");
    }
    return null;
  }

  // Start listening to real-time request updates
  void startListeningToRequests(String userId, String workId) {
    // Cancel any existing subscription
    _requestsSubscription?.cancel();

    // Start listening to real-time updates from user's subcollection
    _requestsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('requests')
        .where('jobId', isEqualTo: workId)
        .snapshots()
        .listen(
          (snapshot) async {
            final List<Reqstmodel> combinedlist = [];

            for (var doc in snapshot.docs) {
              try {
                final reqstdata = doc.data() as Map<String, dynamic>;
                final providerId = reqstdata['providerId'] as String? ?? '';
                final jobId = reqstdata['jobId'] as String? ?? '';
                final profiledata = await fetchproviderProfile(providerId);
                final status = reqstdata['status'] as String? ?? "pending";
                final userphone =
                    FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
                final finalamount =
                    reqstdata['finalAmount'] is num
                        ? reqstdata['finalAmount'].toDouble()
                        : 0.0;
                //  final upiId = reqstdata['upiId'] ?? "";

                if (profiledata != null && status != "Rejected") {
                  combinedlist.add(
                    Reqstmodel(
                      upiId: profiledata['upiId'] as String? ?? '',
                      finalamount: finalamount,
                      userId: userId,
                      phonenumber: profiledata['phone'] as String? ?? '',
                      id: doc.id,
                      status: status,
                      providerid: providerId,
                      jobId: jobId,
                      name:
                          profiledata['fullname'] as String? ??
                          profiledata['name'] as String? ??
                          '',
                      imagepath:
                          profiledata['imageurl'] as String? ??
                          profiledata['imagepath'] as String? ??
                          '',
                      experience: profiledata['experience']?.toString() ?? '',
                      hourlypayment:
                          profiledata['payment'] as String? ??
                          profiledata['hourlypayment'] as String? ??
                          '',
                      jobs:
                          profiledata['categories'] != null
                              ? (profiledata['categories'] is List
                                  ? List<String>.from(profiledata['categories'])
                                  : [profiledata['categories'].toString()])
                              : (profiledata['jobs'] != null
                                  ? (profiledata['jobs'] is List
                                      ? List<String>.from(profiledata['jobs'])
                                      : [profiledata['jobs'].toString()])
                                  : []),
                    ),
                  );
                }
              } catch (e) {
                debugPrint("Error processing request document ${doc.id}: $e");
              }
            }
            _requests = combinedlist;
            notifyListeners();
          },
          onError: (error) {
            debugPrint("Error listening to requests: $error");
          },
        );
  }

  // merge request and profile (for backward compatibility)
  Future<void> loadrequest(String userId, String workId) async {
    final List<Reqstmodel> combinedlist = [];

    final requestsnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('requests')
            .where('jobId', isEqualTo: workId)
            .get();
    for (var doc in requestsnapshot.docs) {
      try {
        final reqstdata = doc.data() as Map<String, dynamic>;
        final providerId = reqstdata['providerId'] as String? ?? '';
        final jobId = reqstdata['jobId'] as String? ?? '';
        final profiledata = await fetchproviderProfile(providerId);
        final status = reqstdata['status'] as String? ?? "pending";
        final finalamount =
            reqstdata['finalAmount'] is num
                ? reqstdata['finalAmount'].toDouble()
                : 0.0;
        //  final upiId = reqstdata['upiId'] ?? "";
        if (profiledata != null && status != "Rejected") {
          combinedlist.add(
            Reqstmodel(
              upiId: profiledata['upiId'] as String? ?? '',
              finalamount: finalamount,
              userId: userId,
              phonenumber: profiledata['phone'] as String? ?? '',
              id: doc.id,
              status: status,
              providerid: providerId,
              jobId: jobId,
              name:
                  profiledata['fullname'] as String? ??
                  profiledata['name'] as String? ??
                  '',
              imagepath:
                  profiledata['imageurl'] as String? ??
                  profiledata['imagepath'] as String? ??
                  '',
              experience: profiledata['experience']?.toString() ?? '',
              hourlypayment:
                  profiledata['payment'] as String? ??
                  profiledata['hourlypayment'] as String? ??
                  '',
              jobs:
                  profiledata['categories'] != null
                      ? (profiledata['categories'] is List
                          ? List<String>.from(profiledata['categories'])
                          : [profiledata['categories'].toString()])
                      : (profiledata['jobs'] != null
                          ? (profiledata['jobs'] is List
                              ? List<String>.from(profiledata['jobs'])
                              : [profiledata['jobs'].toString()])
                          : []),
            ),
          );
        }
      } catch (e) {
        debugPrint("Error loading request document ${doc.id}: $e");
      }
    }
    _requests = combinedlist;
    notifyListeners();
  }

  // Method to send a request to a service provider and notify them
  Future<void> sendRequestToProvider({
    required String userId,
    required String providerId,
    required String workId,
    required String userName,
  }) async {
    try {
      // Create the request data
      final requestData = {
        'userId': userId,
        'providerId': providerId,
        'jobId': workId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
        'userName': userName,
      };

      // Add the request to the provider's requests subcollection
      final docRef = await FirebaseFirestore.instance
          .collection('services')
          .doc(providerId)
          .collection('requests')
          .add(requestData);

      // Also add to global requests collection for easier querying
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(docRef.id)
          .set({
            ...requestData,
            'providerDocPath': 'services/$providerId',
            'requestDocId': docRef.id,
          });

      // Send notification to the service provider
      await NotificationService().sendNotificationToUser(
        userId: providerId,
        title: 'New Service Request',
        body: '$userName has requested your service',
      );

      debugPrint('Request sent successfully to provider $providerId');
    } catch (e) {
      debugPrint("Failed to send request to provider: $e");
      rethrow;
    }
  }

  Future<void> updaterequeststatus({
    required String userId,
    required String reqstId,
    required String newstatus,
    required String workId,
  }) async {
    try {
      // Update the request in the user's subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('requests')
          .doc(reqstId)
          .update({'status': newstatus});

      // Also update the request in the global collection
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(reqstId)
          .update({'status': newstatus});

      if (newstatus == "Rejected") {
        _requests.removeWhere((req) => req.id == reqstId);
        notifyListeners();
      } else {
        // For other status updates, reload the requests to reflect changes
        await loadrequest(userId, workId);
      }
    } catch (e) {
      debugPrint("Failed to update request status: $e");
    }
  }

  Future<int> getCompletedWorksCount(String providerId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("works")
            .where("providerId", isEqualTo: providerId)
            .where("status", isEqualTo: "Completed")
            .get();

    return snapshot.docs.length;
  }

  // Method to stop listening to requests
  void stopListeningToRequests() {
    _requestsSubscription?.cancel();
    _requestsSubscription = null;
  }
}
