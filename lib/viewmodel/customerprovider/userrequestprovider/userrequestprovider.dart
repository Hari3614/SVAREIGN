import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<void> loadrequest(String userId) async {
    final List<Reqstmodel> combinedlist = [];
    final requestsnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('requests')
            .get();
    for (var doc in requestsnapshot.docs) {
      final reqstdata = doc.data();
      final providerId = reqstdata['providerId'];
      final jobId = reqstdata['jobId'];
      final profiledata = await fetchproviderProfile(providerId);
      if (profiledata != null) {
        combinedlist.add(
          Reqstmodel(
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
}
