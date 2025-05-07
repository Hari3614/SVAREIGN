import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class Userservice {
  Future<String?> getuseraddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>;
    final lat = data['location']['latitude'];
    final long = data['location']['longitude'];
    final placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.locality}, ${place.administrativeArea}";
    }
    return null;
  }
}

final Userservice userservice = Userservice();
