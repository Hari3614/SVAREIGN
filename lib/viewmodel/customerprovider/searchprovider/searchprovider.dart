import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/utils/calculatedistance/calculatedistance.dart';

class Searchprovider with ChangeNotifier {
  final FirebaseFirestore _firebasefirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _searchresults = [];
  List<Map<String, dynamic>> get searchresults => _searchresults;
  Timer? _debounce;
  String? _userPlace;
  String? get userPlace => _userPlace;
  double? _userLat;
  double? _userLng;

  void setUserLocation(double lat, double lng) {
    _userLat = lat;
    _userLng = lng;
  }

  void debouncesearch(String query, String place) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchserviceprovider(query);
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
      // Also cache user location
      _userLat = data?['location']?['latitude']?.toDouble();
      _userLng = data?['location']?['longitude']?.toDouble();
      return userPlace;
    } catch (e) {
      print('Error fetching place: $e');
      return null;
    }
  }

  Future<void> searchserviceprovider(String searchquery) async {
    try {
      _searchresults = [];
      final serviceprovidersnapshot =
          await _firebasefirestore.collection('services').get();
      List<Map<String, dynamic>> tempresults = [];
      for (var providerdoc in serviceprovidersnapshot.docs) {
        final providerdocdata = providerdoc.data();

        // Filter by radius if user location available
        if (_userLat != null && _userLng != null) {
          final lat = providerdocdata['location']?['latitude'];
          final lng = providerdocdata['location']?['longitude'];
          if (lat != null && lng != null) {
            final distance = calculateDistance(
              _userLat!,
              _userLng!,
              (lat as num).toDouble(),
              (lng as num).toDouble(),
            );
            if (distance > 20) continue; // 20 km radius
          }
        }

        final profilesnapshot =
            await providerdoc.reference.collection('profile').get();
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
    _debounce?.cancel();
    super.dispose();
  }
}
