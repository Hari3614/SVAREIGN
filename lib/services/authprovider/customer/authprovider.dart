import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svareign/utils/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/utils/phonenumbernormalise/normalise_phonenumber.dart';
import '../../location_services/location_services.dart';
import '../../../view/screens/Authentication/customer_signup_screen/otpscreen/otp_screen.dart';

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
    _phone = normalisephonenumber(phonenumber);
    _password = password;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phone,
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
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Please allow location permission'),
                            ),
                          );
                          Navigator.pop(context);
                        });

                        return const Scaffold(body: SizedBox());
                      } else if (snapshot.hasData) {
                        return OtpScreen(
                          verificationId: verificationId,
                          name: name,
                          email: email,
                          phoneNumber: phonenumber,
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
          print('verificationid: $verificationId');
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
      final normalisedphone = normalisephonenumber(_phone!);

      await _firestore.collection("users").doc(normalisedphone).set({
        'uid': userCredential.user!.uid,
        'name': _name,
        'email': _email,
        'phone': normalisedphone,
        'password': _password,
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'createdAt': Timestamp.now(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeContainer()),
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
      final normalisedphone = normalisephonenumber("+91${phone}");
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(normalisedphone).get();
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
