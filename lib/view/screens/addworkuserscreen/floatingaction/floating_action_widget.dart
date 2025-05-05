import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';

class FloatingActionWidget extends StatefulWidget {
  const FloatingActionWidget({super.key});

  @override
  State<FloatingActionWidget> createState() => _FloatingActionWidgetState();
}

class _FloatingActionWidgetState extends State<FloatingActionWidget> {
  final TextEditingController worknamecontroller = TextEditingController();
  final TextEditingController _description = TextEditingController();
  int _currentcharacter = 0;
  final _maxcharacter = 500;
  String _selectedcategory = "";
  DateTime? _selecteddate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

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

  Future<TimeOfDay?> showTimePickerDialog(
    BuildContext context,
    TimeOfDay initialTime,
  ) async {
    TimeOfDay? selectedTime = initialTime;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Time"),
          content: SizedBox(
            height: 180,
            child: SpinnerTimePicker(
              initTime: initialTime,
              is24HourFormat: false,
              spinnerHeight: 150,
              spinnerWidth: 60,
              elementsSpace: 8,
              digitHeight: 40,
              spinnerBgColor: Colors.grey.shade200,
              selectedTextStyle: TextStyle(
                color: Colors.blueAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              nonSelectedTextStyle: TextStyle(color: Colors.grey, fontSize: 16),
              onChangedSelectedTime: (TimeOfDay time) {
                selectedTime = time;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), // Confirm
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    return selectedTime;
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
                SizedBox(height: 20),
                Text("Select Time Range", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("From: ", style: TextStyle(fontSize: 16)),
                    InkWell(
                      onTap: () async {
                        final result = await showTimePickerDialog(
                          context,
                          _startTime ?? TimeOfDay(hour: 11, minute: 0),
                        );
                        if (result != null) {
                          setState(() {
                            _startTime = result;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(border: Border.all()),
                        child: Text(
                          _startTime != null
                              ? _startTime!.format(context)
                              : "From time",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("To: ", style: TextStyle(fontSize: 16)),
                    InkWell(
                      onTap: () async {
                        final result = await showTimePickerDialog(
                          context,
                          _endTime ?? TimeOfDay(hour: 12, minute: 0),
                        );
                        if (result != null) {
                          setState(() {
                            _endTime = result;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(border: Border.all()),
                        child: Text(
                          _endTime != null
                              ? _endTime!.format(context)
                              : "To time",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
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
                      onPressed: () {},
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
