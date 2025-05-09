import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svareign/services/location_services/location_services.dart';
import 'package:svareign/services/sharedpreferences/session_manager.dart';
import 'package:svareign/utils/phonenumbernormalise/normalise_phonenumber.dart';
import 'package:svareign/view/screens/Authentication/serivice_provider/otp_service_screen/otp_service_screen.dart';

import 'package:svareign/view/screens/dummy_screen.dart';

class ServiceAuthprovider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  String? _name, _email, _phonenumber, _password;
  String _verificationId = "";

  Future<void> sendServiceOtp({
    required String name,
    required String email,
    required String phonenumber,
    required String password,
    required BuildContext context,
  }) async {
    _name = name;
    _email = email;
    _phonenumber = normalisephonenumber(phonenumber);
    _password = password;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phonenumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto verification completed');
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("OTP FAILED: $e")));
        },
        codeSent: (String verificationID, int? resendToken) {
          _verificationId = verificationID;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FutureBuilder<Position>(
                    future: _locationService.getCurrentLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please allow location access"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          Navigator.pop(context);
                        });
                        return const Scaffold(body: SizedBox());
                      } else if (snapshot.hasData) {
                        return OtpServiceScreen(
                          verificationId: verificationID,
                          name: name,
                          email: email,
                          phoneNumber: _phonenumber!,
                          location: snapshot.data!,
                        );
                      } else {
                        return const Scaffold(
                          body: Center(child: Text('Unexpected error')),
                        );
                      }
                    },
                  ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending OTP ")));
    }
  }

  Future<void> verifyandsignUp({
    required String otp,
    required BuildContext context,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      Position position = await _locationService.getCurrentLocation();
      final normalisedphonenumber = normalisephonenumber(_phonenumber!);
      final String role = "service provider";
      await _firebaseFirestore
          .collection("services")
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'name': _name,
            'email': _email,
            'phone': normalisedphonenumber,
            'password': _password,
            'role': role,
            'location': {
              'latitude': position.latitude,
              'longitude': position.longitude,
            },
            'createdAt': Timestamp.now(),
          });
      await SessionManager.Saveusersession(
        uid: userCredential.user!.uid,
        role: role,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DummyScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    }
  }

  Future<void> loginwithphoneandpassword({
    required String phonenumber,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final normalisedphone = normalisephonenumber("+91${phonenumber}");
      QuerySnapshot snapshot =
          await _firebaseFirestore
              .collection('services')
              .where('phone', isEqualTo: normalisedphone)
              .get();
      if (snapshot.docs.isNotEmpty) {
        final userdoc = snapshot.docs.first;
        if (userdoc['password'] == password) {
          await SessionManager.Saveusersession(
            uid: userdoc['uid'],
            role: userdoc['role'],
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DummyScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Invalid credentials')));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }
}
