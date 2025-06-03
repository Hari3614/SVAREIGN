import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Forgetotpscreen extends StatefulWidget {
  final String verificationId;
  final String phone;
  final String role;

  const Forgetotpscreen({
    super.key,
    required this.verificationId,
    required this.phone,
    required this.role,
  });

  @override
  _ForgetotpscreenState createState() => _ForgetotpscreenState();
}

class _ForgetotpscreenState extends State<Forgetotpscreen> {
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;
  late String verificationId;

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
  }

  void verifyOTPAndResetPassword() async {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (otp.length != 6 || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid OTP and new password")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Password reset successful")));
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User not found")));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String newVerificationId, int? resendToken) {
        setState(() {
          verificationId = newVerificationId;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("OTP resent")));
      },
      codeAutoRetrievalTimeout: (String newVerificationId) {
        verificationId = newVerificationId;
      },
    );
  }

  @override
  void dispose() {
    //  otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.1,
                width: width * 1,
                child: Lottie.asset(
                  "assets/lottie/Animation - 1747214410477.json",
                ),
              ),
              SizedBox(height: height * 0.05),
              Text(
                "Password Reset",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(
                "We sent a code to +91 ${widget.phone}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PinCodeTextField(
                  controller: otpController,
                  appContext: context,
                  length: 6,
                  onChanged: (_) {},
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: height * 0.06,
                    fieldWidth: width * 0.12,
                    inactiveColor: Colors.grey,
                    selectedColor: Colors.black,
                    activeColor: Colors.blue,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    hintText: "Enter your new password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.black87,
                  minimumSize: Size(width * 0.87, height * 0.066),
                ),
                onPressed: isLoading ? null : verifyOTPAndResetPassword,
                child:
                    isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'Verify & Reset Password',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: resendOTP,
                    child: Text(
                      "Resend Code",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
