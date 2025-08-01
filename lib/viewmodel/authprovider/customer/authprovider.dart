import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:svareign/services/sharedpreferences/session_manager.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/utils/phonenumbernormalise/normalise_phonenumber.dart';
import '../../../services/location_services/location_services.dart';
import '../../../view/screens/Authentication/customer_signup_screen/otpscreen/otp_screen.dart';

class Authprovider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService locationservice = LocationService();

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
      await _auth.verifyPhoneNumber(
        phoneNumber: _phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Autoverification completed');
        },
        verificationFailed: (FirebaseAuthException e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('OTP Failed: ${e.message}')));
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          _verificationId = verificationId;

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FutureBuilder<Position>(
                    future: locationservice.getCurrentLocation(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Please allow location permission',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
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
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error sending OTP: $e")));
      }
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

      Position position = await locationservice.getCurrentLocation(context);
      final normalisedphone = normalisephonenumber(_phone!);
      final String role = "customer";

      // Save user data to Firestore
      await _firestore.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'name': _name,
        'email': _email,
        'phone': normalisedphone,
        'role': role,
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'createdAt': Timestamp.now(),
      });

      await SessionManager.SaveUserSession(
        uid: user.uid,
        role: role,
        name: _name!,
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeContainer()),
        );
      }
    } catch (e) {
      print('error :$e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No account found with this email")),
          );
        }
        return;
      }

      final role = userDoc['role'];
      await SessionManager.SaveUserSession(uid: uid, role: role, name: _name!);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeContainer()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
      }
    }
  }
}
