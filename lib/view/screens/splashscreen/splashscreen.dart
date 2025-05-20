import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/view/screens/providerscreen/bottomnavbar/bottomnavbarscreen.dart';
import 'package:svareign/view/screens/providerscreen/homescreen/home_screen.dart';
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

  Future<void> navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash effect delay

    User? user = FirebaseAuth.instance.currentUser;

    user ??= await FirebaseAuth.instance.authStateChanges().first;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    Widget nextScreen;

    if (user != null && role != null) {
      if (role == 'customer') {
        nextScreen = const HomeContainer();
      } else if (role == 'service provider') {
        nextScreen = const Servicehomecontainer();
      } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/Animation - 1745218778865.json'),
            const SizedBox(height: 16),
            const Text(
              'S V A R E I G N',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
