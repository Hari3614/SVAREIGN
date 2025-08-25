import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';
import 'package:svareign/model/serviceprovider/bookingmodel.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';

class Bookingprovider with ChangeNotifier {
  bool isloading = false;
  List<Bookingmodel> bookings = [];
  Future<void> fetchbookings() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    isloading = true;
    notifyListeners();

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('bookings')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();
      print("ouerysnapshot ${querySnapshot.docs.length}");
      List<Bookingmodel> tempList = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final bookingUserId = data['userId'];
        final providerId = data['serviceId'];

        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(bookingUserId)
                .get();

        final userData = userDoc.data() ?? {};
        final providerProfileDoc =
            await FirebaseFirestore.instance
                .collection('services')
                .doc(providerId)
                .collection('profile')
                .limit(1)
                .get();
        final providerdata =
            providerProfileDoc.docs.isNotEmpty
                ? providerProfileDoc.docs.first.data()
                : {};
        print("data ${providerProfileDoc.docs.length}");
        final booking = Bookingmodel.fromMap(
          data: data,
          bookingId: doc.id,

          name: providerdata['fullname'] ?? 'Unknown',
          imagePath: providerdata['imageurl'] ?? '',
          // phoneNumber: providerdata['phone'] ?? '',
        );

        tempList.add(booking);
      }

      bookings = tempList;
    } catch (e) {
      print("Error fetching bookings: $e");
    } finally {
      isloading = false;
      notifyListeners();
    }
  }

  Future<void> bookservice({
    required Fetchserviceprovidermodel service,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String description,
    required Cartprovider cartprovider,
  }) async {
    final userid = FirebaseAuth.instance.currentUser?.uid;
    if (userid == null) return;

    isloading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': userid,
        'providerId': service.serviceId,
        'serviceId': service.serviceId,
        'serviceName': service.name,
        'role': service.role,
        'image': service.imagepath,
        'description': description,
        'bookingDate':
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        'bookingTime':
            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      cartprovider.removefromcart(service.serviceId);
    } catch (e) {
      debugPrint("Booking failed: $e");
      rethrow;
    } finally {
      isloading = false;
      notifyListeners();
    }
  }
}
