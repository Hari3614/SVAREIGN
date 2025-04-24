import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svareign/utils/bottomnavbar/bottomnav_screen.dart';
import '../../services/location_services.dart';
import '../../view/screens/Authentication/otpscreen/otp_screen.dart';
import '../../view/screens/homescreen/homescreen.dart';

class Authprovider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService locationservice = LocationService();

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
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Autoverification completed');
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('OTP Failed: ${e.message}')));
        },
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FutureBuilder<Position>(
                    future: locationservice.getCurrentLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(child: Text('Location error')),
                        );
                      } else {
                        return OtpScreen(
                          verificationId: verificationId,
                          name: name,
                          email: email,
                          phoneNumber: phonenumber,
                          // location: snapshot
                        );
                      }
                    },
                  ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print('verificationid:${verificationId}');
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

      Position position = await locationservice.getCurrentLocation();

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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } catch (e) {
      print('error :$e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    }
  }

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
          MaterialPageRoute(builder: (context) => HomeContainer()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid credentials')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }
}
