import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/widgets/cached_image.dart';
import 'package:svareign/services/sharedpreferences/session_manager.dart';
import 'package:svareign/view/screens/Authentication/customer_signup_screen/signupscreen.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/view/screens/Authentication/roleselectionpage/role_selection_page.dart';
import 'package:svareign/view/screens/Authentication/serivice_provider/service_signup_screen.dart';
import 'package:svareign/view/screens/customerscreen/bottomnavbar/bottomnav_screen.dart';
import 'package:svareign/view/screens/providerscreen/bottomnavbar/bottomnavbarscreen.dart'
    show Servicehomecontainer;
import 'package:svareign/view/screens/providerscreen/profilescreen/widget/editprofile/editprofile.dart';
import 'package:svareign/view/screens/settings/settings_screen.dart';
import 'package:svareign/viewmodel/service_provider/serviceprofileprovider/serviceprofileprovider.dart';

class Profilehelpers extends StatefulWidget {
  const Profilehelpers({super.key});

  @override
  State<Profilehelpers> createState() => _ProfilehelpersState();
}

class _ProfilehelpersState extends State<Profilehelpers> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () =>
          Provider.of<Serviceprofileprovider>(
            context,
            listen: false,
          ).fetchProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Consumer<Serviceprofileprovider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profile == null) {
          return const Center(child: Text("No profile data found."));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: width,
                    height: height * 0.26,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.15),
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
                        color: Theme.of(context).cardTheme.color,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                          ),
                        ],
                        border: Border.all(
                          color:
                              Theme.of(context).dividerTheme.color ??
                              Colors.grey.shade300,
                        ),
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
                                print('Selected image: ${pickedFile.path}');
                              }
                            },
                            child: AppCachedAvatar(
                              imageUrl: profile.imageurl,
                              radius: 60,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            profile.fullname,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  final uidText = "user@${profile.id}";
                                  Clipboard.setData(
                                    ClipboardData(text: uidText),
                                  );
                                  Fluttertoast.showToast(
                                    msg: 'Copied to clipboard',
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                  );
                                },
                              ),
                              Text(
                                "user@${profile.id}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // buildProfileTile(Icons.edit, 'Edit Profile', context, () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder:
              //           (context) => EditProfileScreen(
              //             currentName: provider.profile!.fullname,
              //             currentUpi: provider.profile!.upiId,
              //             currentImageUrl: provider.profile!.imageurl,
              //             currentpayment: provider.profile!.payment,
              //           ),
              //     ),
              //   ).then((_) {
              //     Provider.of<Serviceprofileprovider>(
              //       context,
              //       listen: false,
              //     ).fetchProfile();
              //   });
              // }),
              // buildProfileTile(Icons.settings, 'Settings', context, () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => SettingsScreen()),
              //   );
              // }),

              //    buildProfileTile(Icons.shopping_bag, 'My orders', context),
              // ListTile(
              //   leading: const Icon(Icons.logout, color: Colors.red),
              //   title: const Text(
              //     'Logout',
              //     style: TextStyle(
              //       color: Colors.red,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              //   onTap: () {
              //     showDialog(
              //       context: context,
              //       builder:
              //           (context) => AlertDialog(
              //             title: const Text("Logout Confirmation"),
              //             content: const Text("Are you sure want to logout ?"),
              //             actions: [
              //               TextButton(
              //                 onPressed: () {
              //                   Navigator.pop(context);
              //                 },
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
              //  const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).dividerTheme.color ??
                            Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.settings,
                            size: 22,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Loginscreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).dividerTheme.color ??
                            Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.add,
                            size: 22,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Add another account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.switch_account),
                        const SizedBox(width: 16),
                        const Text(
                          'Switch account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
          ),
        );
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
                    child: const Icon(Icons.info_outline),
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
    if (accounts.length <= 1) {
      Fluttertoast.showToast(
        msg: 'No other accounts to switch to',
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return;
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

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
                final isCurrentAccount = uid == currentUid;
                final displayName = name.isNotEmpty ? name : 'Unknown';
                final roleLabel =
                    role == 'customer' ? 'Customer' : 'Service Provider';
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isCurrentAccount
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: TextStyle(
                          color:
                              isCurrentAccount
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            isCurrentAccount
                                ? Theme.of(context).colorScheme.primary
                                : null,
                      ),
                    ),
                    subtitle: Text(
                      '$roleLabel${isCurrentAccount ? ' (Active)' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isCurrentAccount)
                          IconButton(
                            icon: const Icon(Icons.switch_account),
                            onPressed: () async {
                              await SessionManager.SaveUserSession(
                                uid: uid,
                                role: role,
                                name: name,
                              );
                              Navigator.pop(context);
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
                                    builder:
                                        (context) => Servicehomecontainer(),
                                  ),
                                );
                              }
                            },
                          ),
                        if (!isCurrentAccount)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await SessionManager.removeAccount(uid, role);
                              Navigator.pop(context);
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

  Widget buildProfileTile(
    IconData icon,
    String title,
    BuildContext context,
    VoidCallback ontap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: ontap,
    );
  }
}
