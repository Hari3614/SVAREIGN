import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/model/customer/fetchserviceprovider.dart';
import 'package:svareign/viewmodel/customerprovider/bookingprovider/bookingprovider.dart';
import 'package:svareign/viewmodel/customerprovider/cartprovider/cartprovider.dart';

class Bookingscreen extends StatefulWidget {
  const Bookingscreen({super.key, required this.serviceitem});
  final Fetchserviceprovidermodel serviceitem;
  @override
  State<Bookingscreen> createState() => _BookingscreenState();
}

class _BookingscreenState extends State<Bookingscreen> {
  DateTime? selecteddate;
  TimeOfDay? selectedtime;
  final TextEditingController descriptioncontroller = TextEditingController();
  bool isbooking = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(title: Text("Book service")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                selecteddate == null
                    ? "Select Date"
                    : '${selecteddate!.day}/${selecteddate!.month}/${selecteddate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() {
                    selecteddate = picked;
                  });
                }
              },
            ),
            ListTile(
              title: Text(
                selectedtime == null
                    ? "Select Time"
                    : "${selectedtime!.hour}:${selectedtime!.minute.toString().padLeft(2, '0')}",
              ),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picker = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picker != null) {
                  setState(() {
                    selectedtime = picker;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptioncontroller,
              maxLines: 3,
              decoration: InputDecoration(
                label: Text("Description"),
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed:
                  isbooking
                      ? null
                      : () async {
                        if (selecteddate == null ||
                            selectedtime == null ||
                            descriptioncontroller.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text("All fields are required"),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          isbooking = true;
                        });
                        try {
                          final provider = Provider.of<Bookingprovider>(
                            context,
                            listen: false,
                          );
                          final cartprovider = Provider.of<Cartprovider>(
                            context,
                            listen: false,
                          );
                          final description = descriptioncontroller.text.trim();
                          await provider.bookservice(
                            service: widget.serviceitem,
                            selectedDate: selecteddate!,
                            selectedTime: selectedtime!,
                            description: description,
                            cartprovider: cartprovider,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("Booking succesfull"),
                            ),
                          );
                        } catch (E) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Booking failed"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                fixedSize: Size(width * 0.9, height * 0.06),
              ),
              child:
                  isbooking
                      ? const CircularProgressIndicator()
                      : Text(
                        "Confirm Booking",
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
