import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/utils/phonenumbernormalise/normalise_phonenumber.dart';

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
  bool _obscurePassword = true;
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
      _showToast("Please enter a valid OTP and new password", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _showToast("Password reset successful", Colors.green);
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        _showToast("User not found", Colors.red);
      }
    } on FirebaseAuthException catch (e) {
      _showToast("Error: ${e.message}", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resendOTP() async {
    final normalisedPhone = normalisephonenumber(widget.phone);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: normalisedPhone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        _showToast("Verification failed: ${e.message}", Colors.red);
      },
      codeSent: (String newVerificationId, int? resendToken) {
        setState(() => verificationId = newVerificationId);
        _showToast("OTP resent", Colors.green);
      },
      codeAutoRetrievalTimeout: (String newVerificationId) {
        verificationId = newVerificationId;
      },
    );
  }

  void _showToast(String message, Color bg) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: bg,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _glassInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: kPrimaryAccent.withOpacity(0.8),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(gradient: kAuthGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: height * 0.02),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  // Shield icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          kPrimaryAccent.withOpacity(0.3),
                          kSecondaryAccent.withOpacity(0.15),
                        ],
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      size: 40,
                      color: kSecondaryAccent,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  const Text(
                    "Password Reset",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We sent a code to ${widget.phone}",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  // Glass card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.18),
                              Colors.white.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // OTP fields
                            PinCodeTextField(
                              controller: otpController,
                              appContext: context,
                              length: 6,
                              onChanged: (_) {},
                              keyboardType: TextInputType.number,
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(14),
                                fieldHeight: height * 0.06,
                                fieldWidth: width * 0.11,
                                inactiveColor: Colors.white.withOpacity(0.25),
                                selectedColor: kPrimaryAccent,
                                activeColor: kSecondaryAccent,
                                inactiveFillColor: Colors.white.withOpacity(
                                  0.08,
                                ),
                                selectedFillColor: Colors.white.withOpacity(
                                  0.15,
                                ),
                                activeFillColor: Colors.white.withOpacity(0.12),
                              ),
                              enableActiveFill: true,
                              cursorColor: kPrimaryAccent,
                            ),
                            const SizedBox(height: 20),
                            // Password field
                            TextField(
                              controller: newPasswordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: _glassInputDecoration(
                                label: "New Password",
                                hint: "Enter your new password",
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white54,
                                  ),
                                  onPressed:
                                      () => setState(
                                        () =>
                                            _obscurePassword =
                                                !_obscurePassword,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Verify button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : verifyOTPAndResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child:
                                    isLoading
                                        ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                        : const Text(
                                          "Verify & Reset Password",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Resend row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: resendOTP,
                        child: const Text(
                          "Resend Code",
                          style: TextStyle(
                            color: kSecondaryAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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
      ),
    );
  }
}
