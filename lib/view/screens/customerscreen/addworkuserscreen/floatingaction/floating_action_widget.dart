import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/customer/addwork._model.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/viewmodel/customerprovider/addworkprovider/addworkprovider.dart';

class FloatingActionWidget extends StatefulWidget {
  const FloatingActionWidget({super.key});

  @override
  State<FloatingActionWidget> createState() => _FloatingActionWidgetState();
}

class _FloatingActionWidgetState extends State<FloatingActionWidget> {
  final TextEditingController worknamecontroller = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _minbudgetController = TextEditingController();
  final TextEditingController _maxbudgetcontroller = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  int _currentcharacter = 0;
  final _maxcharacter = 500;
  final AudioPlayer _audioPlayer = AudioPlayer();
  File? _pickedimage;
  String? _imagename;
  final ImagePicker imagePicker = ImagePicker();
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    _description.addListener(() {
      setState(() {
        _currentcharacter = _description.text.length;
      });
    });
  }

  @override
  void dispose() {
    _description.dispose();
    _maxbudgetcontroller.dispose();
    _minbudgetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> pickimage() async {
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _pickedimage = File(image.path);
        _imagename = image.name;
      });
    }
  }

  Future<String> uploadimage(File imagefile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      String filename = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageref = FirebaseStorage.instance
          .ref()
          .child("workimage")
          .child(uid)
          .child("$filename.jpg");
      UploadTask uploadTask = storageref.putFile(imagefile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadurl = await snapshot.ref.getDownloadURL();
      return downloadurl;
    } catch (e) {
      throw Exception("image upload failed :$e");
    }
  }

  Future<void> _postwork() async {
    if (worknamecontroller.text.trim().isEmpty) {
      _showmsg('Please enter a work title');
      return;
    }
    if (_description.text.trim().isEmpty) {
      _showmsg("Please enter the description");
      return;
    }
    if (_minbudgetController.text.trim().isEmpty ||
        double.tryParse(_minbudgetController.text.trim()) == null) {
      _showmsg("Please enter a valid budget");
      return;
    }
    // if (_maxbudgetcontroller.text.trim().isEmpty ||
    //     double.parse(_minbudgetController.text.trim()) >
    //         double.parse(_maxbudgetcontroller.text.trim())) {
    //   _showmsg("Min budget should not be greater than the max budget");
    // }
    if (_durationController.text.trim().isEmpty) {
      _showmsg("Please enter the duration");
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showmsg("user not logged In");
      return;
    }
    setState(() {
      isloading = true;
    });
    String imageurl = await uploadimage(_pickedimage!);

    final firebaseFirestore = FirebaseFirestore.instance;
    final docref = firebaseFirestore.collection('works').doc();

    final work = Addworkmodel(
      status: 'pending',
      id: docref.id,
      userId: user.uid,
      imagepath: imageurl,
      worktittle: worknamecontroller.text.trim(),
      description: _description.text.trim(),
      duration: _durationController.text.trim(),
      maxbudget: double.parse(_maxbudgetcontroller.text.trim()),
      minbudget: double.parse(_minbudgetController.text.trim()),
      postedtime: DateTime.now(),
      // imagepath: _pickedimage?.path,
    );

    print("here the workid${work.id}");
    try {
      await context.read<Workprovider>().addwork(work);
      await _audioPlayer.play(
        AssetSource("sounds/mixkit-hard-pop-click-2364.wav"),
      );
      _showmsg("Work posted successfully", success: true);
      Navigator.of(context).pop();
    } catch (e) {
      _showmsg('Failed to post work: $e');
    }
  }

  void _showmsg(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Post a work",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text("Work Title"),
                SizedBox(height: 10),
                Textfieldwidget(
                  controller: worknamecontroller,
                  labeltext: "Add work title",
                  obscuretext: false,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _description,
                  maxLines: 5,
                  maxLength: _maxcharacter,
                  decoration: InputDecoration(
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
                SizedBox(height: 10),
                Text("Upload Work Image", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: pickimage,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, color: Colors.blueAccent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _imagename ?? "Tap to upload an Image",
                            style: TextStyle(
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (_pickedimage != null)
                          Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Budget (₹)", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Textfieldwidget(
                        controller: _minbudgetController,
                        labeltext: "Min Budget",
                        obscuretext: false,
                        inputType: TextInputType.numberWithOptions(),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Textfieldwidget(
                        controller: _maxbudgetcontroller,
                        labeltext: "Max Budget",
                        obscuretext: false,
                        inputType: TextInputType.numberWithOptions(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text("Duration", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Textfieldwidget(
                  controller: _durationController,
                  labeltext: "E.g. 3 days, 1 week / hours",
                  obscuretext: false,
                ),
                SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    height: height * 0.06,
                    width: width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _postwork,
                      child:
                          isloading
                              ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                "Post",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
