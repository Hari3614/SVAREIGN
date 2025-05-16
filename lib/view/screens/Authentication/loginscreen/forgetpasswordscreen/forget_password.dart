import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/forgetpasswordscreen/forgetotpscreen.dart';

class ForgetPasswordscreen extends StatefulWidget {
  final String role;
  const ForgetPasswordscreen({super.key, required this.role});

  @override
  State<ForgetPasswordscreen> createState() => _ForgetPasswordscreenState();
}

class _ForgetPasswordscreenState extends State<ForgetPasswordscreen> {
  final TextEditingController phoneController = TextEditingController();

  void sendOTP() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      showMessage("Please enter your phone number");
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        showMessage("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => Forgetotpscreen(
                  verificationId: verificationId,
                  phone: phone,
                  role: widget.role,
                ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.35,
              width: width,
              child: Image.asset("assets/images/app icon1.png"),
            ),
            Text(
              "Forgot password?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Text(
              "We'll send you an OTP to reset your password.",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Mobile Number",
                  hintText: "Enter your registered number",
                  prefixIcon: Icon(Icons.phone_android),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: sendOTP, child: Text("Send OTP")),
          ],
        ),
      ),
    );
  }
}
