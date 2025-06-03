import 'dart:math';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/authprovider/customer/authprovider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.location,
  });

  final String verificationId;
  final String name;
  final String email;
  final String phoneNumber;
  final Position location;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late TextEditingController otpcontrollerr;
  Timer? timer;
  int start = 30;
  bool _isResendenabled = false;

  @override
  void initState() {
    super.initState();
    otpcontrollerr = TextEditingController();
    starttimer();
  }

  void starttimer() {
    setState(() {
      _isResendenabled = false;
      start = 30;
    });
    timer?.cancel();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (start == 0) {
        setState(() {
          _isResendenabled = true;
        });
        t.cancel();
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // otpcontrollerr.dispose();
    timer?.cancel();
  }

  // final String location;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // final TextEditingController otpcontroller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            height: height * 0.45,
            width: width * 0.93,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: width * 0.07, // Responsive text
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.02),
                Text(
                  'A verification code has been \nsent to +91 ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.03),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: otpcontrollerr,
                  animationCurve: Curves.bounceInOut,
                  animationType: AnimationType.slide,
                  autoDismissKeyboard: true,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {},
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: height * 0.06,
                    fieldWidth: width * 0.1,
                    activeColor: Colors.grey,
                    selectedColor: Colors.black,
                    inactiveColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    print("otp :${otpcontrollerr.text}");
                    if (otpcontrollerr.text.length == 6) {
                      print('otp send :${otpcontrollerr.text}');
                      context.read<Authprovider>().verifyotpandsignup(
                        otp: otpcontrollerr.text,
                        context: context,
                      );

                      print('text :${otpcontrollerr.text}');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter a valid OTP")),
                      );
                      print('error :$e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, height * 0.065),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Verify',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          _isResendenabled
                              ? () {
                                // Resend OTP functionality
                                context.read<Authprovider>().sendotp(
                                  name: widget.name,
                                  email: widget.email,
                                  phonenumber: widget.phoneNumber,
                                  password: '', // Handle password if needed
                                  context: context,
                                );
                                starttimer();
                              }
                              : null,
                      child: Text(
                        _isResendenabled
                            ? 'Resend code'
                            : "Resend in $start sec",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _isResendenabled ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                // Optional: Show location info (you could display this if needed)
                // Text(
                //   'Location: $location', // Example of displaying location
                //   style: TextStyle(fontSize: 12, color: Colors.grey),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
