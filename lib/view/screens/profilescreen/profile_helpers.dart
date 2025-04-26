import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/viewmodel/customer/profile_view_model.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final ProfileviewModeldata = Provider.of<ProfileViewModel>(context);
    final user = ProfileviewModeldata.user;
    final currentuser = FirebaseAuth.instance.currentUser;
    final fullphonenumber = currentuser?.phoneNumber;
    // final phonenumber = fullphonenumber?.replaceAll('+91', '');
    if (fullphonenumber != null && ProfileviewModeldata.user == null) {
      Future.microtask(() => ProfileviewModeldata.fetchuser(fullphonenumber));
    }
    if (ProfileviewModeldata.user == null) {
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
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.04),
                        CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.person, size: 50),
                        ), // User Name
                        Spacer(),
                        Text(
                          user?.name ?? "Unknown",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),

                        // User ID
                        const SizedBox(height: 6),
                        Text(
                          " User@${user?.uid}" ?? "1234",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Profile Options
        buildProfileTile(Icons.edit, 'Edit Profile'),
        buildProfileTile(Icons.settings, 'Settings'),

        // Logout Button
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          ),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Loginscreen()),
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

  Widget buildProfileTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
