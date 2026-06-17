import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/viewmodel/authprovider/customer/authprovider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  final String verificationId;
  final String name;
  final String email;
  final String phoneNumber;

  static Future<void> show(
    BuildContext context, {
    required String verificationId,
    required String name,
    required String email,
    required String phoneNumber,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder:
          (_) => OtpScreen(
            verificationId: verificationId,
            name: name,
            email: email,
            phoneNumber: phoneNumber,
          ),
    );
  }

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late TextEditingController otpcontrollerr;
  Timer? timer;
  int start = 30;
  bool _isResendenabled = false;
  bool _isVerifying = false;
  bool _isResending = false;

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
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (start == 0) {
        setState(() => _isResendenabled = true);
        t.cancel();
      } else {
        setState(() => start--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Scaffold(
          backgroundColor: kPrimaryDark,
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryAccent.withOpacity(0.15),
                    border: Border.all(color: kPrimaryAccent.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    color: kPrimaryAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Verify Your Number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A verification code has been\nsent to +91 ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // PIN fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: otpcontrollerr,
                    backgroundColor: Colors.transparent,
                    animationCurve: Curves.easeInOut,
                    animationType: AnimationType.fade,
                    autoDismissKeyboard: true,
                    keyboardType: TextInputType.number,
                    cursorColor: kPrimaryAccent,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (_) {},
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(14),
                      fieldHeight: 52,
                      fieldWidth: 44,
                      activeColor: kPrimaryAccent,
                      selectedColor: kSecondaryAccent,
                      inactiveColor: Colors.white.withOpacity(0.2),
                      activeFillColor: Colors.white.withOpacity(0.08),
                      selectedFillColor: kPrimaryAccent.withOpacity(0.1),
                      inactiveFillColor: Colors.transparent,
                    ),
                    enableActiveFill: true,
                  ),
                ),
                const SizedBox(height: 24),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isVerifying
                            ? null
                            : () async {
                              if (otpcontrollerr.text.length == 6) {
                                setState(() => _isVerifying = true);
                                try {
                                  await context
                                      .read<Authprovider>()
                                      .verifyotpandsignup(
                                        otp: otpcontrollerr.text,
                                        context: context,
                                      );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isVerifying = false);
                                  }
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Please enter a valid OTP',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryAccent,
                      disabledBackgroundColor: kPrimaryAccent.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isVerifying
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
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
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          (_isResendenabled && !_isResending && !_isVerifying)
                              ? () async {
                                setState(() => _isResending = true);
                                try {
                                  await context.read<Authprovider>().resendOtp(
                                    context: context,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isResending = false);
                                    starttimer();
                                  }
                                }
                              }
                              : null,
                      child:
                          _isResending
                              ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kSecondaryAccent,
                                ),
                              )
                              : Text(
                                _isResendenabled
                                    ? 'Resend code'
                                    : 'Resend in $start sec',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isResendenabled
                                          ? kSecondaryAccent
                                          : Colors.white.withOpacity(0.35),
                                ),
                              ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
