import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svareign/services/sharedpreferences/session_manager.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/utils/phonenumbernormalise/normalise_phonenumber.dart';
import '../../../view/screens/Authentication/customer_signup_screen/otpscreen/otp_screen.dart';

class Authprovider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _name, _email, _phone, _password;
  String _verificationId = "";

  // Send OTP to phone number
  Future<void> sendotp({
    required String name,
    required String email,
    required String phonenumber,
    required String password,
    required BuildContext context,
  }) async {
    _name = name;
    _email = email;
    _phone = normalisephonenumber(phonenumber);
    _password = password;

    try {
      final completer = Completer<void>();
      await _auth.verifyPhoneNumber(
        phoneNumber: _phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Autoverification completed');
          if (!completer.isCompleted) completer.complete();
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(
            msg: 'OTP Failed: ${e.message}',
            backgroundColor: Colors.red,
          );
          if (!completer.isCompleted) completer.complete();
        },
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;

          if (!context.mounted) return;

          OtpScreen.show(
            context,
            verificationId: verificationId,
            name: name,
            email: email,
            phoneNumber: phonenumber,
          );
          if (!completer.isCompleted) completer.complete();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print('verificationid: $verificationId');
        },
      );
      await completer.future;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error sending OTP: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  // Resend OTP without navigating or overwriting password
  Future<void> resendOtp({required BuildContext context}) async {
    if (_phone == null) return;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phone!,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(
            msg: 'Resend failed: ${e.message}',
            backgroundColor: Colors.red,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          Fluttertoast.showToast(
            msg: 'OTP resent successfully',
            backgroundColor: Colors.green,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error resending OTP: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  // Verify OTP and complete signup
  Future<void> verifyotpandsignup({
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

      final emailCredential = EmailAuthProvider.credential(
        email: _email!,
        password: _password!,
      );
      await user!.linkWithCredential(emailCredential);

      // Get location silently (permission already requested at splash)
      Map<String, dynamic>? locationData;
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        locationData = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
      } catch (_) {
        // Location unavailable — save without it
      }

      final normalisedphone = normalisephonenumber(_phone!);
      final String role = "customer";

      // Save user data to Firestore
      await _firestore.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'name': _name,
        'email': _email,
        'phone': normalisedphone,
        'role': role,
        if (locationData != null) 'location': locationData,
        'createdAt': Timestamp.now(),
      });

      await SessionManager.SaveUserSession(
        uid: user.uid,
        role: role,
        name: _name!,
      );

      if (context.mounted) {
        // Close the OTP bottom sheet
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeContainer()),
        );
      }
    } catch (e) {
      print('error :$e');
      Fluttertoast.showToast(
        msg: 'Signup failed: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  // Login using email and password
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final userDoc = await _firestore.collection("users").doc(uid).get();

      if (!userDoc.exists) {
        if (context.mounted) {
          Fluttertoast.showToast(
            msg: 'No account found with this email',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
        return;
      }

      final role = userDoc['role'];
      final name = userDoc['name'];
      await SessionManager.SaveUserSession(uid: uid, role: role, name: name);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeContainer()),
        );
      }
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

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      String message = "Login failed. Please try again.";
      if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        message = "Network error. Please check your internet connection.";
      }

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }
}
