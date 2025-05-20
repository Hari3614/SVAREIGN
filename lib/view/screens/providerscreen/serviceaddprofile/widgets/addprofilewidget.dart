import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/serviceprovider/setup_profilemodel.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/view/screens/providerscreen/homescreen/home_screen.dart';
import 'package:svareign/viewmodel/service_provider/setupprofile/setupprofile_provider.dart';

class Addprofilewidget extends StatefulWidget {
  const Addprofilewidget({super.key});

  @override
  State<Addprofilewidget> createState() => _AddprofilewidgetState();
}

class _AddprofilewidgetState extends State<Addprofilewidget> {
  final TextEditingController _namecntrler = TextEditingController();
  final TextEditingController _descriptioncntrller = TextEditingController();
  final TextEditingController _paymentcontrlr = TextEditingController();
  int _maxcharacter = 500;

  File? _pickedimage;
  final List<String> _categories = [
    'Plumber',
    'Electrician',
    "Painter",
    "Carpenter",
    "Cleaner",
    "Laundry",
    "Packers and Movers",
    "Ac Techinician",
    "Glass cleaning",
    "Sanitary Work",
    "Tank Cleaning",
    "others",
  ];
  List<String> _selectedcategory = [];
  final List<String> _experienceoptions = [
    "Less than 1 year",
    "1-2 years",
    "2-5 years",
    "5+ years",
  ];
  String? _selectedexperience;
  Future<void> pickimage() async {
    final pickedfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedfile != null) {
      setState(() {
        _pickedimage = File(pickedfile.path);
      });
    }
  }

  Future<String> uploadimage(File imagefile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(uid)
          .child('$filename.jpg');
      UploadTask uploadTask = storageref.putFile(imagefile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadurl = await snapshot.ref.getDownloadURL();
      return downloadurl;
    } catch (e) {
      throw Exception('Image upload failed ;$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        SizedBox(height: 15),
        Positioned(
          height: height * 0.6,
          width: width / 2 - 52,
          child: InkWell(
            enableFeedback: true,
            onTap: pickimage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage:
                  _pickedimage != null
                      ? FileImage(_pickedimage!)
                      : AssetImage(
                        "assets/images/pngtree-add-friendcontact-web-button-for-social-media-profile-vector-png-image_41767694.jpg",
                      ),
            ),
          ),
        ),
        SizedBox(height: 30),
        Textfieldwidget(
          controller: _namecntrler,
          labeltext: "Full Name",
          obscuretext: false,
          color: Colors.black,
          hinttext: "Enter your name",
          preffixicon: Icons.person,
          inputType: TextInputType.name,
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child: Text(
              "Service categories",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 5),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child: Text(
              "(You can choose categories)",
              style: TextStyle(color: Colors.black26),
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Wrap(
            spacing: 10,
            children:
                _categories.map((category) {
                  final _iselected = _selectedcategory.contains(category);
                  return ChoiceChip(
                    label: Text(category),
                    selected: _iselected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedcategory.length < 3) {
                            _selectedcategory.add(category);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.blueAccent,
                                content: Text(
                                  "You can select upto 3 categories",
                                ),
                              ),
                            );
                          }
                        } else {
                          _selectedcategory.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child: Text(
              "Work description",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: TextFormField(
            controller: _descriptioncntrller,
            maxLines: 5,
            maxLength: _maxcharacter,

            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.black),
              ),
              focusColor: Colors.black,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: "Work Description",
              hintText: "Tell about your work...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child: Text(
              "Experience",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 10),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Experience",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.black),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              hintText: "Select Experience",
            ),

            items:
                _experienceoptions.map((String experience) {
                  return DropdownMenuItem<String>(
                    value: experience,
                    child: Text(experience),
                  );
                }).toList(),

            value: _selectedexperience,
            onChanged: (String? newvalue) {
              setState(() {
                _selectedexperience = newvalue;
              });
            },
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: width * 0.05),
            child: Text(
              "Hourly Payment",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 10),
        Textfieldwidget(
          controller: _paymentcontrlr,
          labeltext: "Payment",
          obscuretext: false,
          hinttext: "payment/hour",
          color: Colors.black,
          inputType: TextInputType.number,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            fixedSize: Size(width * 0.9, height * 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            final name = _namecntrler.text.trim();
            final description = _descriptioncntrller.text.trim();
            final payment = _paymentcontrlr.text.trim();
            if (name.isEmpty || description.isEmpty || payment.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("All fields are Required")),
              );
            }
            if (_pickedimage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please select a profile image")),
              );
              return;
            }

            if (name.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Name is required")));
              return;
            }

            if (_selectedcategory.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Please select at least one service category"),
                ),
              );
              return;
            }

            if (description.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Work description is required")),
              );
              return;
            }

            if (_selectedexperience == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please select your experience level")),
              );
              return;
            }

            if (payment.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Hourly payment is required")),
              );
              return;
            }
            try {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => Center(child: CircularProgressIndicator()),
              );
              String imageurl = await uploadimage(_pickedimage!);
              final serviceId = FirebaseAuth.instance.currentUser!.uid;
              Profile profile = Profile(
                id: serviceId,
                fullname: name,
                description: description,
                experience: _selectedexperience!,
                categories: _selectedcategory,
                imageurl: imageurl,
                payment: payment,
              );
              await Provider.of<Profileprovider>(
                context,
                listen: false,
              ).addprofile(profile);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DummyScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Profile add Succesfully'),
                ),
              );
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error :${e.toString()}")));
            }
          },
          child: Text(
            "Setup",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
