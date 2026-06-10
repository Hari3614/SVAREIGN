import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svareign/services/location_services/location_services.dart';
import 'package:svareign/services/sharedpreferences/session_manager.dart';
import 'package:svareign/utils/phonenumbernormalise/normalise_phonenumber.dart';
import 'package:svareign/view/screens/Authentication/serivice_provider/otp_service_screen/otp_service_screen.dart';
import 'package:svareign/view/screens/providerscreen/bottomnavbar/bottomnavbarscreen.dart';

import 'package:svareign/view/screens/providerscreen/serviceaddprofile/serviceaddprofie.dart';

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
      final completer = Completer<void>();
      await _auth.verifyPhoneNumber(
        phoneNumber: _phonenumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Auto verification completed');
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("OTP FAILED: $e")));
          if (!completer.isCompleted) completer.complete();
        },
        codeSent: (String verificationID, int? resendToken) {
          _verificationId = verificationID;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OtpServiceScreen(
                    verificationId: verificationID,
                    name: name,
                    email: email,
                    phoneNumber: _phonenumber!,
                  ),
            ),
          );
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      await completer.future;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending OTP ")));
    }
  }

  // Resend OTP without navigating or overwriting password
  Future<void> resendServiceOtp({required BuildContext context}) async {
    if (_phonenumber == null) return;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phonenumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resend failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error resending OTP: $e")));
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
      User? user = userCredential.user;
      final emailcredential = EmailAuthProvider.credential(
        email: _email!,
        password: _password!,
      );
      await user!.linkWithCredential(emailcredential);
      Position position = await _locationService.getCurrentLocation(context);
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
            'role': role,
            'location': {
              'latitude': position.latitude,
              'longitude': position.longitude,
            },
            'createdAt': Timestamp.now(),
          });
      await SessionManager.SaveUserSession(
        uid: userCredential.user!.uid,
        role: role,
        name: _name!,
      );
      //   await saveFcmtoken(userCredential.user!.uid);
      // setupTokenRefreshListener(userCredential.user!.uid);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Serviceaddprofie()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    }
  }

  // Future<void> loginwithphoneandpassword({
  //   required String phonenumber,
  //   required String password,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     final normalisedphone = normalisephonenumber("+91${phonenumber}");
  //     QuerySnapshot snapshot =
  //         await _firebaseFirestore
  //             .collection('services')
  //             .where('phone', isEqualTo: normalisedphone)
  //             .get();
  //     if (snapshot.docs.isNotEmpty) {
  //       final userdoc = snapshot.docs.first;
  //       if (userdoc['password'] == password) {
  //         await SessionManager.Saveusersession(
  //           uid: userdoc['uid'],
  //           role: userdoc['role'],
  //         );
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => DummyScreen()),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(SnackBar(content: Text('Invalid credentials')));
  //       }
  //     } else {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('User not found')));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
  //   }
  // }
  Future<void> loginwithemailandpassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final userdoc =
          await _firebaseFirestore.collection('services').doc(uid).get();
      if (!userdoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No account Found With this e-mail")),
        );
        return;
      }
      final role = userdoc['role'];
      final name = userdoc['name'];
      await SessionManager.SaveUserSession(uid: uid, role: role, name: name);
      // await saveFcmtoken(uid);
      //setupTokenRefreshListener(uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Servicehomecontainer()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";
      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'network-request-failed') {
        message = "Network error. Please check your internet connection.";
      } else {
        message = e.message ?? "Login failed";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      String message = "Login failed. Please try again.";
      if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        message = "Network error. Please check your internet connection.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
