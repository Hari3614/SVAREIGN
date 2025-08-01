import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/serviceprovider/jobsadsmodel.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/viewmodel/service_provider/jobads/jobadsprovider.dart';

class Serviceaddwidget extends StatefulWidget {
  const Serviceaddwidget({super.key});

  @override
  State<Serviceaddwidget> createState() => _ServiceaddwidgetState();
}

class _ServiceaddwidgetState extends State<Serviceaddwidget> {
  final TextEditingController tittlecontroller = TextEditingController();
  final TextEditingController descriptioncntrlr = TextEditingController();
  final TextEditingController budgetcontrlr = TextEditingController();
  int maxlenght = 500;
  TimeOfDay? startime;
  TimeOfDay? endtime;
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> selectedImages = [];
  bool _isLoading = false;

  void _picktime({required bool isStartime}) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartime) {
          startime = picked;
        } else {
          endtime = picked;
        }
      });
    }
  }

  Future<List<String>> uploadimages() async {
    final provider = FirebaseAuth.instance.currentUser?.uid;
    final storage = FirebaseStorage.instance;

    List<Future<String>> uploadFutures =
        selectedImages.map((image) async {
          final ref = storage.ref().child(
            'service_images/$provider/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
          );
          await ref.putFile(File(image.path));
          return await ref.getDownloadURL();
        }).toList();

    return await Future.wait(uploadFutures);
  }

  Future<void> _pickimages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      if (selectedImages.length + images.length > 3) {
        final remaining = 3 - selectedImages.length;
        setState(() {
          selectedImages.addAll(images.take(remaining));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You can only select up to 3 images")),
        );
      } else {
        setState(() {
          selectedImages.addAll(images);
        });
      }
    }
  }

  void removeimages(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Add Your Posts",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Textfieldwidget(
                controller: tittlecontroller,
                labeltext: "Job title",
                obscuretext: false,
                hinttext: "Enter your job title",
              ),
              SizedBox(height: 30),
              TextField(
                maxLength: maxlenght,
                maxLines: 5,
                controller: descriptioncntrlr,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  hintText:
                      "Example@ We are offering discounted AC installation service valid till May 30th",
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Textfieldwidget(
                controller: budgetcontrlr,
                labeltext: "Budget",
                obscuretext: false,
                hinttext: "Enter your budget/hour",
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedImages.length >= 3 ? null : _pickimages,
                child: Text(
                  "Add Images Max 3",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              if (selectedImages.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(selectedImages.length, (index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(selectedImages[index].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => removeimages(index),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _picktime(isStartime: true),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          startime != null
                              ? "${startime!.format(context)} "
                              : "Start time",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _picktime(isStartime: false),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          endtime != null
                              ? endtime!.format(context)
                              : "End Time",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fixedSize: Size(width * 0.89, height * 0.06),
                ),
                onPressed:
                    _isLoading
                        ? null
                        : () async {
                          final tittle = tittlecontroller.text.trim();
                          final description = descriptioncntrlr.text.trim();
                          final budget = budgetcontrlr.text.trim();

                          if (tittle.isEmpty ||
                              description.isEmpty ||
                              budget.isEmpty ||
                              startime == null ||
                              endtime == null ||
                              selectedImages.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please fill all the fields and add at least one image",
                                ),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            final imageurl = await uploadimages();
                            final providerId =
                                FirebaseAuth.instance.currentUser!.uid;
                            final post = Jobsadsmodel(
                              providerid: providerId,
                              tittle: tittle,
                              description: description,
                              budget: double.parse(budget),
                              imageurl: imageurl,
                              starttime: startime!.format(context),
                              endtime: endtime!.format(context),
                              postedtime: DateTime.now(),
                            );
                            await Provider.of<Jobadsprovider>(
                              context,
                              listen: false,
                            ).addpost(post);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.lightGreen,
                                  content: Text("Posted Successfully"),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text("Failed to post. Try again."),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                child:
                    _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          "Post",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
