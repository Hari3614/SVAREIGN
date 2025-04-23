import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svareign/services/location_services.dart';
import 'package:svareign/view/screens/Authentication/otpscreen/otp_screen.dart';
import 'package:svareign/view/screens/homescreen/homescreen.dart';

class Authprovider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Locationservice locationservice = Locationservice();
  // temporary storage during setup
  String? _name, _email, _phone, _password;

  String _verificationId = "";
  Future<void> sendotp({
    required String name,
    required String email,
    required String phonenumber,
    required String password,
    required BuildContext context,
  }) async {
    _name = name;
    _email = email;
    _phone = phonenumber;
    _password = password;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phonenumber',
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('OTP Failed ${e.message}')));
        },
        codeSent: (String verificationId, int? resendtoken) {
          _verificationId = verificationId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OtpScreen(
                    verificationId: verificationId,
                    name: name,
                    email: email,
                    phoneNumber: phonenumber,
                    location: locationservice.toString(),
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
      ).showSnackBar(SnackBar(content: Text("Error sending OTP: $e")));
    }
  }

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
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _firestore.collection("users").doc(_phone).set({
        'uid': userCredential.user!.uid,
        'name': _name,
        'email': _email,
        'phone': _phone,
        'password': _password,
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'createdAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('SignUp successfull')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed : $e')));
    }
  }

  //Login with password and phone
  Future<void> loginwithphoneandpassword({
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(phone).get();
      if (userDoc.exists && userDoc['password'] == password) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Homescreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid credentials')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed :$e')));
    }
  }
}
