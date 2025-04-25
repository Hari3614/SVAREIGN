import 'package:flutter/material.dart';
import 'package:svareign/view/screens/profilescreen/profile_helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "My Profile",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ProfileWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
