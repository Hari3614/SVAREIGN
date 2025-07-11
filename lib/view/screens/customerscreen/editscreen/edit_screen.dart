import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/customerprovider/customer/profile_view_model.dart';

class EditProfileDialog extends StatelessWidget {
  final User? user;
  final _nameController = TextEditingController();

  EditProfileDialog({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    _nameController.text = user?.displayName ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                child:
                    user?.photoURL == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Enter your name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () async {
                final newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    await Provider.of<ProfileViewModel>(
                      context,
                      listen: false,
                    ).updateName(newName);
                    _nameController.clear(); // Clear text
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Name updated successfully"),
                      ),
                    );
                  } catch (e) {
                    throw Exception("failed");
                  }
                }
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
