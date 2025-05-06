import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/customer/addwork._model.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/viewmodel/addworkprovider/addworkprovider.dart';

class FloatingActionWidget extends StatefulWidget {
  const FloatingActionWidget({super.key});

  @override
  State<FloatingActionWidget> createState() => _FloatingActionWidgetState();
}

class _FloatingActionWidgetState extends State<FloatingActionWidget> {
  final TextEditingController worknamecontroller = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _minbudgetcontroller = TextEditingController();
  final TextEditingController _maxbudgetcontroller = TextEditingController();
  int _currentcharacter = 0;
  final _maxcharacter = 500;
  String _selectedcategory = "";
  DateTime? _selecteddate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  File? _pickedimage;
  String? _imagename;
  final ImagePicker imagePicker = ImagePicker();
  final List<String> categories = [
    'Plumber',
    'Electician',
    'Painter',
    'Carpenter',
    'AC mechanic',
    'Cleaner',
    'Gardener',
    'Techinican',
    'Other',
  ];

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
    super.dispose();
  }

  void pickdate() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(Duration(days: 365)),
      onConfirm: (date) {
        setState(() {
          _selecteddate = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
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

  Future<void> _postwork() async {
    if (worknamecontroller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SnackBar(content: Text('Please enter a work Tittle')),
        ),
      );
      return;
    }
    if (_description.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please Enter the description")));
      return;
    }
    if (_selectedcategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a category")));
      return;
    }
    if (_selecteddate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please select a date")));
      return;
    }
    final min = int.tryParse(_minbudgetcontroller.text);
    final max = int.tryParse(_maxbudgetcontroller.text);
    if (min == null || max == null) {
      _showmsg('Budget must be numeric');
      return;
    }
    if (min > max) {
      _showmsg('Min budget cannot exceed Max budget');
      return;
    }

    final work = Addworkmodel(
      worktittle: worknamecontroller.text,
      description: _description.text,
      date: DateFormat('dd/MM/yyyy').format(_selecteddate!),
      providername: _selectedcategory,
      minbudget: min,
      maxbudget: max,
    );
    try {
      await context.read<Workprovider>().addwork(work);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Work Posted Completely"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('failed to post work :$e')));
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
          "Post a Work",
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 19,
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
                Text("Upload Work image ", style: TextStyle(fontSize: 16)),
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
                        Text(
                          _imagename ?? "Tap to upload an Image",
                          style: TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_pickedimage != null)
                          Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      categories.map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: _selectedcategory == category,
                          onSelected: (value) {
                            setState(() {
                              _selectedcategory = value ? category : "";
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 10),
                Text("Budget (₹)", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Textfieldwidget(
                        controller: _minbudgetcontroller,
                        labeltext: 'Min',
                        obscuretext: false,
                        inputType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Textfieldwidget(
                        controller: _maxbudgetcontroller,
                        labeltext: "Max",
                        obscuretext: false,
                        inputType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text("Preferred Date", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: pickdate,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selecteddate != null
                              ? DateFormat('dd/MM/yyyy').format(_selecteddate!)
                              : "Select preferred date",
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    height: height * 0.06,
                    width: width * 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _postwork,
                      child: Text(
                        "Post",
                        style: TextStyle(
                          fontSize: 18,
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
