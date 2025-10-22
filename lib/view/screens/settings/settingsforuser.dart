import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:svareign/helperfunctions/delete_helper.dart';
import 'package:svareign/view/screens/customerscreen/editscreen/edit_screen.dart';
import 'package:svareign/view/screens/settings/Privacy_policy_screen.dart';
import 'package:svareign/view/screens/settings/about_screen.dart';
import 'package:svareign/view/screens/settings/customer_agreements_screen.dart';
import 'package:svareign/view/screens/settings/customer_support_screen.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';

class SettingsforuserScreen extends StatelessWidget {
  const SettingsforuserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ---------- General ----------
          buildSectionHeader("General"),
          buildSettingsCard([
            buildSettingsTile(
              icon: Icons.edit_outlined,
              iconBg: Colors.indigo.shade100,
              iconColor: Colors.indigo.shade700,
              title: "Edit Profile",
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: EditProfileDialog(
                          user: FirebaseAuth.instance.currentUser,
                        ),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No user logged in")),
                  );
                }
              },
            ),

            buildDivider(),
            buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              iconBg: Colors.blue.shade100,
              iconColor: Colors.blue.shade700,
              title: "Privacy Policy",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  ),
            ),
            buildDivider(),
            buildSettingsTile(
              icon: Icons.support_agent_outlined,
              iconBg: Colors.green.shade100,
              iconColor: Colors.green.shade700,
              title: "Customer Support",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerSupportScreen(),
                    ),
                  ),
            ),
            buildDivider(),
            buildSettingsTile(
              icon: Icons.description_outlined,
              iconBg: Colors.orange.shade100,
              iconColor: Colors.orange.shade700,
              title: "Customer Agreements",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerAgreementsScreen(),
                    ),
                  ),
            ),
          ]),

          const SizedBox(height: 24),

          /// ---------- App Info ----------
          buildSectionHeader("App Info"),
          buildSettingsCard([
            buildSettingsTile(
              icon: Icons.info_outline,
              iconBg: Colors.purple.shade100,
              iconColor: Colors.purple.shade700,
              title: "About",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
            ),
            buildDivider(),
            buildSettingsTile(
              icon: Icons.system_update_alt_outlined,
              iconBg: Colors.teal.shade100,
              iconColor: Colors.teal.shade700,
              title: "Check for Updates",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You are on the latest version"),
                  ),
                );
              },
            ),
            buildDivider(),
            buildSettingsTile(
              icon: Icons.logout,
              iconBg: Colors.red.shade100,
              iconColor: Colors.red.shade700,
              title: "Logout",
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => Loginscreen()),
                    (route) => false,
                  );
                }
              },
            ),
            buildDivider(),
            buildSettingsTile(
              icon: Icons.delete,
              iconBg: Colors.red.shade100,
              iconColor: Colors.red,
              title: "Delete My Account",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DeleteAccountScreen(role: 'user'),
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// Section Header
  Widget buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  /// Card Container
  Widget buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// Settings Tile
  Widget buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: iconBg,
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.6,
      indent: 60,
      endIndent: 12,
      color: Colors.grey[300],
    );
  }
}
