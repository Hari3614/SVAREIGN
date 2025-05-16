import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/view/screens/customerscreen/editscreen/edit_screen.dart';
import 'package:svareign/viewmodel/customerprovider/customer/profile_view_model.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final user = profileViewModel.user;
    final currentUser = FirebaseAuth.instance.currentUser;

    final uid = currentUser?.uid;
    if (uid != null && profileViewModel.user == null) {
      Future.microtask(() => profileViewModel.fetchUserByUid(uid));
    }

    if (profileViewModel.user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: width,
              height: height * 0.26,
              color: Colors.black87,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 35,
                left: 10,
                right: 10,
                bottom: 30,
              ),
              child: Container(
                height: height * 0.3,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3)],
                  border: Border.all(color: Colors.black87),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.04),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                        );

                        // Handle image update logic here if needed
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            user?.imageUrl != null
                                ? NetworkImage(user!.imageUrl!)
                                : null,
                        child:
                            user?.imageUrl == null
                                ? const Icon(Icons.person, size: 50)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              final uidText = "user@${user?.uid ?? '1234'}";
                              Clipboard.setData(ClipboardData(text: uidText));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            },
                          ),
                          Text(
                            "user@${user?.uid ?? '1234'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Profile Options
        buildProfileTile(Icons.edit, 'Edit Profile', context),
        buildProfileTile(Icons.settings, 'Settings', context),

        // Logout Button
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Loginscreen()),
            );
          },
        ),

        const SizedBox(height: 30),

        // Add Another Account
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.add, size: 22, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Add another account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget buildProfileTile(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (title == "Edit Profile") {
          showDialog(
            context: context,
            builder: (context) {
              return EditProfileDialog(user: FirebaseAuth.instance.currentUser);
            },
          );
        }
      },
    );
  }
}
