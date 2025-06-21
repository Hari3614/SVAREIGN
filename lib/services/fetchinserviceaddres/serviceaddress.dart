import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class Serviceaddress {
  Future<String?> getserviceaddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final snapshot =
        await FirebaseFirestore.instance.collection('services').doc(uid).get();
    if (!snapshot.exists) return null;

    final data = snapshot.data() as Map<String, dynamic>;

    final lat = data['location']['latitude'];
    final long = data['location']['longitude'];

    try {
      final placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality}, ${place.administrativeArea}';
      } else {
        return "Location not found";
      }
    } catch (e) {
      return "Location fetch failed";
    }
  }
}

final serviceaddress = Serviceaddress();
