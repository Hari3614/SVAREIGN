import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class Userservice {
  Future<String?> getuseraddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final docref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await docref.get();
    if (!snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>;
    final lat = data['location']['latitude'];
    final long = data['location']['longitude'];
    try {
      final placemark = await placemarkFromCoordinates(lat, long);
      if (placemark.isNotEmpty) {
        final place = placemark.first;
        final districtname = place.locality;
        final state = place.administrativeArea;
        if (districtname == null || state == null) return 'Invalid address';
        final fullplace = '$districtname,$state';
        final storeplace = data['place'];
        if (storeplace == null || storeplace != null) {
          await docref.set({'place': fullplace}, SetOptions(merge: true));
        }
        return fullplace;
      } else {
        return 'location not found';
      }
    } catch (e) {
      print('error in fetching location :$e');
    }
    return null;
  }
}

final Userservice userservice = Userservice();
