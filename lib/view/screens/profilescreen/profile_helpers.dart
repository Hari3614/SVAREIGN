import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),

        // Profile Icon
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person, size: 50, color: Colors.blue),
        ),

        const SizedBox(height: 12),

        // User Name
        const Text(
          'Hari Prasad',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // User ID
        const SizedBox(height: 6),
        const Text(
          'User ID: 12345678',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),

        const SizedBox(height: 32),

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
          onTap: () {},
        ),

        const SizedBox(height: 40),

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
