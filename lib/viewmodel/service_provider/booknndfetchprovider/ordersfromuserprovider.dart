import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:svareign/model/serviceprovider/bookingmodel.dart';

class Ordersfromuserprovider with ChangeNotifier {
  List<Bookingmodel> _bookings = [];
  List<Bookingmodel> get bookings => _bookings;

  Future<void> fetchbookings() async {
    try {
      _bookings.clear();
      final providerId = FirebaseAuth.instance.currentUser?.uid;
      print("providerID = $providerId");
      if (providerId == null) {
        print("Provider not logged in.");
        return;
      }

      final snapshots =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('providerId', isEqualTo: providerId)
              .get();

      print('Fetched ${snapshots.docs.length} bookings');

      for (var doc in snapshots.docs) {
        final data = doc.data();
        final userId = data['userId'];

        // Check if userId exists
        if (userId == null) {
          print("Missing userId in booking ${doc.id}");
          continue;
        }

        final userdoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        final userdata = userdoc.data() ?? {};

        final booking = Bookingmodel.fromMap(
          data: data,
          bookingId: doc.id,
          name: userdata['name'] ?? '',
          imagePath: userdata['imageurl'] ?? '',
          phoneNumber: userdata['phone'] ?? '',
        );

        _bookings.add(booking);
      }

      notifyListeners();
    } catch (e) {
      print("Error in fetching bookings: $e");
    }
  }

  Future<void> updatebookings(String bookingId, String newstatus) async {
    try {
      final booking = _bookings.firstWhere((b) => b.bookingId == bookingId);
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'status': newstatus});

      await fetchbookings();
      print("booking :$bookingId status updated to $newstatus");
    } catch (e) {
      print("error update status booking :$e");
    }
  }
}
