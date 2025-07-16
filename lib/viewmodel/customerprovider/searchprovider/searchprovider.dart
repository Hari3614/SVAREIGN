import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Searchprovider with ChangeNotifier {
  final FirebaseFirestore _firebasefirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _searchresults = [];
  List<Map<String, dynamic>> get searchresults => _searchresults;
  Timer? _debounce;
  String? _userPlace;
  String? get userPlace => _userPlace;
  void debouncesearch(String query, String place) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchserviceprovider(query, place);
    });
  }

  void setUserPlace(String place) {
    _userPlace = place;
    notifyListeners();
  }

  Future<String?> fetchUserPlace() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!snapshot.exists) {
        print('User document does not exist');
        return null;
      }

      final data = snapshot.data();
      final userPlace = data?['place'];
      return userPlace;
    } catch (e) {
      print('Error fetching place: $e');
      return null;
    }
  }

  Future<void> searchserviceprovider(String searchquery, String place) async {
    try {
      _searchresults = [];
      final serviceprovidersnapshot =
          await _firebasefirestore
              .collection('services')
              .where('place', isEqualTo: place)
              .get();
      List<Map<String, dynamic>> tempresults = [];
      for (var providerdoc in serviceprovidersnapshot.docs) {
        final profilesnapshot =
            await providerdoc.reference.collection('profile').get();
        final providerdocdata = providerdoc.data();
        for (var profiledoc in profilesnapshot.docs) {
          final data = profiledoc.data();
          final List<dynamic> jobs = data['categories'] ?? [];
          if (jobs
              .map((e) => e.toString().toLowerCase())
              .contains(searchquery.toLowerCase())) {
            tempresults.add({
              'name': data['fullname'] ?? '',
              'Jobs': jobs,
              'imageurl': data['imageurl'] ?? "",
              'uid': data['serviceId'] ?? "",
              'experience': data['experience'],
              'description': data['description'] ?? "",
              "phonenumber": providerdocdata['phone'],
            });
          }
        }
      }
      _searchresults = tempresults;
      notifyListeners();
    } catch (e) {
      print('error in search  :$e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _debounce?.cancel();
    super.dispose();
  }
}
