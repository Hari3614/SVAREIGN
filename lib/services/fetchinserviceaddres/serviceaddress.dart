import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

class Serviceaddress {
  Future<String?> getserviceaddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final docref = FirebaseFirestore.instance.collection('services').doc(uid);
    final snapshot = await docref.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data() as Map<String, dynamic>;

    final lat = data['location']['latitude'];
    final long = data['location']['longitude'];

    try {
      final placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final districtname = place.locality;
        final state = place.administrativeArea;
        if (districtname == null || state == null) return "Invalid address";
        final fullplace = "$districtname,$state";
        final Storedplace = data['place'];
        if (Storedplace == null || Storedplace != null) {
          await docref.set({"place": fullplace}, SetOptions(merge: true));
        }
        return fullplace;
      } else {
        return "Location not found";
      }
    } catch (e) {
      print("error fetching failed");
      return "Location fetch failed";
    }
  }
}

final serviceaddress = Serviceaddress();
