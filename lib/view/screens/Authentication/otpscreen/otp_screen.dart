import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/utils/elevatedbutton/elevatedbutton.dart';
import 'package:svareign/view/screens/Authentication/roleselectionpage/role_selection_page.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final TextEditingController otpcontroller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            height: height * 0.45,
            width: width * 0.9,
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
                  'A verification code has been \nsent to +91 9037207889',
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
                  controller: otpcontroller,
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
                  onPressed: () {
                    showroleselectionpage(context);
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
                      "Did'nt recieve the code ?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Resend code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showroleselectionpage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: [
              const Text(
                'Select your Role',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RoleSelectionPage(
                    title: 'Service Provider',
                    imagpath: 'assets/images/app icon1.png',
                    ontap: () {},
                  ),
                  RoleSelectionPage(
                    title: 'User',
                    imagpath: 'assets/images/app icon1.png',
                    ontap: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
