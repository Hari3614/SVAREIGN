import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/view/screens/providerscreen/bottomnavbar/bottomnavbarscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    navigateToNext();
  }

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {
      // Non-blocking — permission will be re-requested later if needed
    }
  }

  Future<void> navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash effect delay

    // Request location permission early so it doesn't interrupt signup
    await _requestLocationPermission();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('IsloggedIn') ?? false;
      String? role = prefs.getString('role');

      Widget nextScreen;

      if (isLoggedIn && role != null) {
        // Session exists - check if Firebase user is still valid
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Wait for Firebase to restore auth state (can take time on cold start)
          user = await FirebaseAuth.instance.authStateChanges().first.timeout(
            const Duration(seconds: 10),
            onTimeout: () => null,
          );
        }

        if (user != null) {
          if (role == 'customer') {
            nextScreen = const HomeContainer();
          } else if (role == 'service provider') {
            nextScreen = const Servicehomecontainer();
          } else {
            nextScreen = const Loginscreen();
          }
        } else {
          // Firebase session truly expired - clear local session
          await prefs.remove('IsloggedIn');
          await prefs.remove('uid');
          await prefs.remove('role');
          nextScreen = const Loginscreen();
        }
      } else {
        nextScreen = const Loginscreen();
      }

      // Ensure context is still valid before navigating
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      }
    } catch (e) {
      print("Error in splash screen navigation: $e");
      // Navigate to login screen in case of any error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Loginscreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kAuthGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryAccent.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Lottie.asset(
                  'assets/lottie/Animation - 1745218778865.json',
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'S V A R E I G N',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Premium Services, Delivered',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
