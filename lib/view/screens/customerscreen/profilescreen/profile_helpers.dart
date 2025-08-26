import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/services/sharedpreferences/session_manager.dart';
import 'package:svareign/view/screens/Authentication/customer_signup_screen/signupscreen.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/view/screens/Authentication/roleselectionpage/role_selection_page.dart';
import 'package:svareign/view/screens/Authentication/serivice_provider/service_signup_screen.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/view/screens/customerscreen/editscreen/edit_screen.dart';
import 'package:svareign/view/screens/customerscreen/myordersscreen/myorders.dart';
import 'package:svareign/view/screens/providerscreen/bottomnavbar/bottomnavbarscreen.dart';
import 'package:svareign/view/screens/settings/settings_screen.dart';
import 'package:svareign/view/screens/settings/settingsforuser.dart';
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
                        if (pickedFile != null) {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;
                          try {
                            final ref = FirebaseStorage.instance
                                .ref()
                                .child('user_profile_images')
                                .child(uid)
                                .child('profile.jpg');
                            final bytes = await pickedFile.readAsBytes();
                            await ref.putData(bytes);
                            final imageurl = await ref.getDownloadURL();
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({'imageurl': imageurl});

                            // Optionally update local state
                            final profileViewModel =
                                Provider.of<ProfileViewModel>(
                                  context,
                                  listen: false,
                                );
                            profileViewModel.updateImageUrl(imageurl);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile picture updated'),
                              ),
                            );
                          } catch (e) {
                            print("Error uploading image :$e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Upload image failed"),
                              ),
                            );
                          }
                        }
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            user?.imageurl != null
                                ? NetworkImage(user!.imageurl!)
                                : null,
                        child:
                            user?.imageurl == null
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
        // buildProfileTile(Icons.edit, 'Edit Profile', context),
        buildProfileTile(Icons.settings, 'Settings', context),
        buildProfileTile(Icons.shopping_bag, 'My orders', context),

        // Logout Button
        // ListTile(
        //   leading: const Icon(Icons.logout, color: Colors.red),
        //   title: const Text(
        //     'Logout',
        //     style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
        //   ),
        //   onTap: () {
        //     showDialog(
        //       context: context,
        //       builder:
        //           (context) => AlertDialog(
        //             title: const Text('Logout Confirmation'),
        //             content: Text("Are you sure want to logout ?"),
        //             actions: [
        //               TextButton(
        //                 onPressed: () => Navigator.pop(context),
        //                 child: Text("Cancel"),
        //               ),
        //               TextButton(
        //                 onPressed: () async {
        //                   Navigator.pop(context);
        //                   await FirebaseAuth.instance.signOut();
        //                   Navigator.pushReplacement(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) => Loginscreen(),
        //                     ),
        //                   );
        //                 },
        //                 child: Text(
        //                   "Logout",
        //                   style: TextStyle(color: Colors.red),
        //                 ),
        //               ),
        //             ],
        //           ),
        //     );
        //   },
        // ),
        const SizedBox(height: 30),

        // Add Another Account
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showroleselectionpage(context);
            },

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

        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showAccountSwitcher(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.switch_account, color: Colors.black),
                  const SizedBox(width: 16),
                  const Text(
                    'Switch account',
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
        } else if (title == "My orders") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyOrders()),
          );
        } else if (title == "Settings") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsforuserScreen(),
            ),
          );
        }
      },
    );
  }

  void showroleselectionpage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              Row(
                children: [
                  const Text(
                    'Select your Role',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text(
                                'Role Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Service Provider: Offers services like plumbing, electrical work, etc.',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Customer: Can browse and book service providers.',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    child: const Icon(Icons.info_outline, color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RoleSelectionPage(
                    title: 'Service Provider',
                    imagpath: 'assets/lottie/Animation - 1745910686886.json',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ServiceSignupScreen(
                                usertype: "serviceprovider",
                              ),
                        ),
                      );
                    },
                  ),
                  RoleSelectionPage(
                    title: 'Customer',
                    imagpath: 'assets/lottie/Animation - 1745917229976.json',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Signupscreen(usertype: "user"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void showAccountSwitcher(BuildContext context) async {
    final accounts = await SessionManager.getAllAccounts();
    if (accounts.length <= 1) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Switch Accounts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...accounts.map((acc) {
                final uid = acc['uid']!;
                final role = acc['role']!;
                final name = acc['name']!;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text("UID: ${uid.substring(0, 6)}..."),
                    subtitle: Text("Role: $role"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.switch_account),
                          onPressed: () async {
                            await SessionManager.SaveUserSession(
                              uid: uid,
                              role: role,
                              name: name,
                            );
                            Navigator.pop(context); // Close the sheet
                            if (role == "customer") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeContainer(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Servicehomecontainer(),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await SessionManager.removeAccount(uid, role);
                            Navigator.pop(
                              context,
                            ); // Close and reopen to refresh
                            showAccountSwitcher(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
