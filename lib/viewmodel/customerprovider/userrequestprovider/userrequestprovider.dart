import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/reqstmodel.dart';

class Userrequestprovider extends ChangeNotifier {
  List<Reqstmodel> _requests = [];
  List<Reqstmodel> get request => _requests;
  //fetch profile
  Future<Map<String, dynamic>?> fetchproviderProfile(String providerId) async {
    try {
      final profilesnapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(providerId)
              .collection('profile')
              .limit(1)
              .get();
      if (profilesnapshot.docs.isNotEmpty) {
        return profilesnapshot.docs.first.data();
      }
    } catch (e) {
      debugPrint("error fetching provider profile");
    }
    return null;
  }

  // merge request and profile
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
      final reqstdata = doc.data();
      final providerId = reqstdata['providerId'];
      final jobId = reqstdata['jobId'];
      final profiledata = await fetchproviderProfile(providerId);
      final status = reqstdata['status'] ?? "pending";
      final userphone = FirebaseAuth.instance.currentUser?.phoneNumber;
      final finalamount = reqstdata['finalAmount'] ?? 0.0;
      if (profiledata != null && status != "Rejected") {
        combinedlist.add(
          Reqstmodel(
            finalamount: finalamount,
            userId: userId,
            phonenumber: userphone!,
            id: doc.id,
            status: status,
            providerid: providerId,
            jobId: jobId,
            name: profiledata['fullname'],
            imagepath: profiledata['imageurl'],
            experience: profiledata['experience'],
            hourlypayment: profiledata['payment'],
            jobs:
                profiledata['categories'] != null
                    ? List<String>.from(profiledata['categories'])
                    : null,
          ),
        );
      }
    }
    _requests = combinedlist;
    notifyListeners();
  }

  Future<void> updaterequeststatus({
    required String userId,
    required String reqstId,
    required String newstatus,
    required String workId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('requests')
          .doc(reqstId)
          .update({'status': newstatus});
      if (newstatus == "Rejected") {
        _requests.removeWhere((req) => req.id == reqstId);
        notifyListeners();
      }
      await loadrequest(userId, workId);
    } catch (e) {
      debugPrint("Failed to update request status: $e");
    }
  }
}
