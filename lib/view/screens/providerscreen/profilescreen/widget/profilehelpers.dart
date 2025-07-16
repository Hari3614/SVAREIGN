import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
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
                    color: Colors.lightGreen,
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
                        boxShadow: const [
                          BoxShadow(color: Colors.grey, blurRadius: 3),
                        ],
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
                                print('Selected image: ${pickedFile.path}');
                              }
                            },
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  (profile.imageurl != null &&
                                          profile.imageurl!.isNotEmpty)
                                      ? NetworkImage(profile.imageurl!)
                                      : null,
                              child:
                                  (profile.imageurl == null ||
                                          profile.imageurl!.isEmpty)
                                      ? const Icon(Icons.person, size: 50)
                                      : null,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ),
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

              buildProfileTile(Icons.edit, 'Edit Profile', context),
              buildProfileTile(Icons.settings, 'Settings', context),

              //    buildProfileTile(Icons.shopping_bag, 'My orders', context),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Loginscreen(),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 30),

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
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(
                            Icons.add,
                            size: 22,
                            color: Colors.black,
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
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget buildProfileTile(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title tapped')));
      },
    );
  }
}
