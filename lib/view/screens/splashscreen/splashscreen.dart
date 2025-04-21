import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.white,

      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/Animation - 1745218778865.json'),
          Text(
            'S V A R E I G N',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: 500,
      duration: 3000,
      nextScreen: Loginscreen(),
    );
  }
}
