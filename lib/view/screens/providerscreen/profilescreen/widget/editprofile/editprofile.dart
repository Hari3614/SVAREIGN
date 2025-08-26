import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/service_provider/setupprofile/setupprofile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentUpi;
  final String? currentImageUrl;
  final String? currentpayment;
  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentUpi,
    this.currentImageUrl,
    required this.currentpayment,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _upiController;
  late TextEditingController _paymentcontroller;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _upiController = TextEditingController(text: widget.currentUpi);
    _paymentcontroller = TextEditingController(text: widget.currentpayment);
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final provider = Provider.of<Profileprovider>(context, listen: false);

        // Upload image if new one is selected
        String? imageUrl = widget.currentImageUrl;
        if (_newImage != null) {
          imageUrl = await provider.uploadProfileImage(
            _newImage!,
          ); // 🔹 new function
        }

        await provider.updateProfile(
          name: _nameController.text.trim(),
          upiId: _upiController.text.trim(),
          payment: _paymentcontroller.text.trim(),
          imageUrl: imageUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Update failed: $e")));
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _newImage != null
                          ? FileImage(_newImage!)
                          : (widget.currentImageUrl != null &&
                              widget.currentImageUrl!.isNotEmpty)
                          ? NetworkImage(widget.currentImageUrl!)
                          : null,
                  child:
                      (_newImage == null &&
                              (widget.currentImageUrl == null ||
                                  widget.currentImageUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
              ),
              const SizedBox(height: 20),

              // Service Provider Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Service Provider Name",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 16),

              // UPI ID
              TextFormField(
                controller: _upiController,
                decoration: const InputDecoration(
                  labelText: "UPI ID",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Enter UPI ID" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentcontroller,
                decoration: const InputDecoration(
                  labelText: 'Hourly payment',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Enter UPI ID" : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
