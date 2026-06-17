import 'package:flutter/material.dart';
import 'package:svareign/view/screens/customerscreen/profilescreen/profile_helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            "My Profile",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SingleChildScrollView(child: ProfileWidget()),
    );
  }
}
