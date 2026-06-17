import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/model/serviceprovider/setup_profilemodel.dart';

class Serviceprofileprovider with ChangeNotifier {
  Profile? profile;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    final serviceProviderId = FirebaseAuth.instance.currentUser?.uid;
    if (serviceProviderId == null) {
      print("No user logged in");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc(serviceProviderId)
              .collection('profile')
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        profile = Profile.frommap(snapshot.docs.first.data());
        print("Fetched profile: ${snapshot.docs.first.data()}");
      } else {
        // Fallback: read name from root service document
        final serviceDoc =
            await FirebaseFirestore.instance
                .collection('services')
                .doc(serviceProviderId)
                .get();
        if (serviceDoc.exists) {
          final data = serviceDoc.data() as Map<String, dynamic>;
          profile = Profile(
            fullname: data['name'] as String? ?? 'Unknown',
            imageurl: data['imageurl'] as String?,
            payment: '',
            upiId: '',
            phone: data['phone'] as String?,
          );
          print("Fetched profile from root doc: ${data['name']}");
        } else {
          // Last fallback: try users collection (customer who switched to provider view)
          final userDoc =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(serviceProviderId)
                  .get();
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            profile = Profile(
              fullname: data['name'] as String? ?? 'Unknown',
              imageurl: data['imageurl'] as String?,
              payment: '',
              upiId: '',
              phone: data['phone'] as String?,
            );
            print("Fetched profile from users doc: ${data['name']}");
          } else {
            // Final fallback: use Firebase Auth display name
            final user = FirebaseAuth.instance.currentUser;
            profile = Profile(
              fullname: user?.displayName ?? 'Unknown',
              imageurl: user?.photoURL,
              payment: '',
              upiId: '',
              phone: user?.phoneNumber,
            );
            print("Using Firebase Auth fallback for profile");
          }
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
