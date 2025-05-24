import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/serviceprovider/setup_profilemodel.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/view/screens/providerscreen/bottomnavbar/bottomnavbarscreen.dart';
import 'package:svareign/view/screens/providerscreen/homescreen/home_screen.dart';
import 'package:svareign/view/screens/providerscreen/serviceworkscreen/serviceworkscreen.dart';
import 'package:svareign/viewmodel/service_provider/setupprofile/setupprofile_provider.dart';

class Addprofilewidget extends StatefulWidget {
  const Addprofilewidget({super.key});

  @override
  State<Addprofilewidget> createState() => _AddprofilewidgetState();
}

class _AddprofilewidgetState extends State<Addprofilewidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  int _maxCharacter = 500;
  bool isloading = false;

  File? _pickedImage;

  final List<String> _categories = [
    'Plumber',
    'Electrician',
    "Painter",
    "Carpenter",
    "Cleaner",
    "Laundry",
    "Packers and Movers",
    "Ac Technician",
    "Glass cleaning",
    "Sanitary Work",
    "Tank Cleaning",
    "Others",
  ];
  List<String> _selectedCategories = [];

  final List<String> _experienceOptions = [
    "Less than 1 year",
    "1-2 years",
    "2-5 years",
    "5+ years",
  ];
  String? _selectedExperience;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(uid)
          .child('$filename.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          InkWell(
            onTap: pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : const AssetImage(
                            "assets/images/pngtree-icon-add-people-profile-new-button-vector-png-image_26219400.jpg",
                          )
                          as ImageProvider,
            ),
          ),
          const SizedBox(height: 30),
          Textfieldwidget(
            controller: _nameController,
            labeltext: "Full Name",
            obscuretext: false,
            color: Colors.black,
            hinttext: "Enter your name",
            preffixicon: Icons.person,
            inputType: TextInputType.name,
          ),
          const SizedBox(height: 20),
          _buildCategorySection(width),
          const SizedBox(height: 10),
          _buildDescriptionSection(),
          _buildExperienceSection(width),
          const SizedBox(height: 10),
          _buildPaymentField(),
          const SizedBox(height: 30),
          _buildSubmitButton(context, width, height),
        ],
      ),
    );
  }

  Widget _buildCategorySection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Service categories", width),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Wrap(
            spacing: 10,
            children:
                _categories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedCategories.length < 3) {
                            _selectedCategories.add(category);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "You can select up to 3 categories",
                                ),
                              ),
                            );
                          }
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, double width) {
    return Padding(
      padding: EdgeInsets.only(left: width * 0.05, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 5,
        maxLength: _maxCharacter,
        decoration: InputDecoration(
          labelText: "Work Description",
          hintText: "Tell about your work...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceSection(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: DropdownButtonFormField<String>(
        value: _selectedExperience,
        items:
            _experienceOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedExperience = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: "Experience",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildPaymentField() {
    return Textfieldwidget(
      controller: _paymentController,
      labeltext: "Payment",
      obscuretext: false,
      hinttext: "payment/hour",
      color: Colors.black,
      inputType: TextInputType.number,
    );
  }

  Widget _buildSubmitButton(BuildContext context, double width, double height) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        fixedSize: Size(width * 0.9, height * 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed:
          isloading
              ? null
              : () async {
                final name = _nameController.text.trim();
                final description = _descriptionController.text.trim();
                final payment = _paymentController.text.trim();

                if (_pickedImage == null) {
                  _showMessage("Please select a profile image");
                } else if (name.isEmpty) {
                  _showMessage("Name is required");
                } else if (_selectedCategories.isEmpty) {
                  _showMessage("Please select at least one service category");
                } else if (description.isEmpty) {
                  _showMessage("Work description is required");
                } else if (_selectedExperience == null) {
                  _showMessage("Please select your experience level");
                } else if (payment.isEmpty ||
                    double.tryParse(payment) == null) {
                  _showMessage("Valid hourly payment is required");
                } else {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (_) =>
                              const Center(child: CircularProgressIndicator()),
                    );
                    final imageUrl = await uploadImage(_pickedImage!);
                    final uid = FirebaseAuth.instance.currentUser!.uid;

                    final profile = Profile(
                      id: uid,
                      fullname: name,
                      description: description,
                      experience: _selectedExperience!,
                      categories: _selectedCategories,
                      imageurl: imageUrl,
                      payment: payment,
                    );

                    await Provider.of<Profileprovider>(
                      context,
                      listen: false,
                    ).addprofile(profile);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Servicehomecontainer(),
                      ),
                    );

                    _showMessage("Profile added successfully", success: true);
                  } catch (e) {
                    Navigator.of(context).pop(); // Close dialog
                    _showMessage("Error: ${e.toString()}");
                  }
                }
              },
      child:
          isloading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text(
                "Setup",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
