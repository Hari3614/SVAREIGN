import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';

class Serviceprofilesceen extends StatelessWidget {
  const Serviceprofilesceen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await logoutuser();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Loginscreen()),
            );
          },
          child: Text("Logout"),
        ),
      ),
    );
  }

  Future<void> logoutuser() async {
    FirebaseAuth.instance.signOut();
  }
}
