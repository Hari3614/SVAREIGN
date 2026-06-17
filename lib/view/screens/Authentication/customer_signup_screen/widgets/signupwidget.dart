import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/authprovider/customer/authprovider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/viewmodel/passwordvisiblity/password_visiblity_provider.dart';
import 'package:svareign/viewmodel/signupformprovider/form_provider.dart';

class Signupwidget extends StatefulWidget {
  const Signupwidget({super.key});

  @override
  State<Signupwidget> createState() => _SignupwidgetState();
}

class _SignupwidgetState extends State<Signupwidget> {
  final namecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    namecontroller.dispose();
    emailcontroller.dispose();
    phonecontroller.dispose();
    passwordcontroller.dispose();
    confirmcontroller.dispose();
    super.dispose();
  }

  InputDecoration _glassInput({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white70, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      errorStyle: TextStyle(color: Colors.red.shade300, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Container(
      decoration: const BoxDecoration(gradient: kAuthGradient),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                SizedBox(height: height * 0.03),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.015),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign up as a Customer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: height * 0.025),

                // Glass form card
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
                          TextFormField(
                            controller: namecontroller,
                            style: const TextStyle(color: Colors.white),
                            decoration: _glassInput(
                              label: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                            validator:
                                (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Enter your name'
                                        : null,
                            onChanged:
                                (v) => Provider.of<Signupformprovide>(
                                  context,
                                  listen: false,
                                ).updatefield('name', v),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: emailcontroller,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: _glassInput(
                              label: 'Email',
                              icon: Icons.email_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter email';
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            onChanged:
                                (v) => Provider.of<Signupformprovide>(
                                  context,
                                  listen: false,
                                ).updatefield('email', v),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: phonecontroller,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: _glassInput(
                              label: 'Mobile Number',
                              icon: Icons.phone_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter phone';
                              if (v.length != 10) return 'Must be 10 digits';
                              return null;
                            },
                            onChanged:
                                (v) => Provider.of<Signupformprovide>(
                                  context,
                                  listen: false,
                                ).updatefield('phone', v),
                          ),
                          const SizedBox(height: 16),
                          Consumer<PasswordVisiblityProvider>(
                            builder: (context, vis, _) {
                              return TextFormField(
                                controller: passwordcontroller,
                                obscureText: vis.isobscured,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInput(
                                  label: 'Password',
                                  icon: Icons.lock_outline,
                                  suffix: IconButton(
                                    onPressed: vis.togglevisiblity,
                                    icon: Icon(
                                      vis.isobscured
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Enter password';
                                  if (v.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                                onChanged: (v) {
                                  Provider.of<Signupformprovide>(
                                    context,
                                    listen: false,
                                  ).updatefield('password', v);
                                  _formKey.currentState!.validate();
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Consumer<PasswordVisiblityProvider>(
                            builder: (context, vis, _) {
                              return TextFormField(
                                controller: confirmcontroller,
                                obscureText: vis.isobscured,
                                style: const TextStyle(color: Colors.white),
                                decoration: _glassInput(
                                  label: 'Confirm Password',
                                  icon: Icons.lock_person_outlined,
                                  suffix: IconButton(
                                    onPressed: vis.togglevisiblity,
                                    icon: Icon(
                                      vis.isobscured
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v != passwordcontroller.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                onChanged: (v) {
                                  Provider.of<Signupformprovide>(
                                    context,
                                    listen: false,
                                  ).updatefield('confirmpassword', v);
                                  _formKey.currentState!.validate();
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() => _isLoading = true);
                                          try {
                                            await Provider.of<Authprovider>(
                                              context,
                                              listen: false,
                                            ).sendotp(
                                              name: namecontroller.text.trim(),
                                              email:
                                                  emailcontroller.text.trim(),
                                              phonenumber:
                                                  phonecontroller.text.trim(),
                                              password:
                                                  passwordcontroller.text
                                                      .trim(),
                                              context: context,
                                            );
                                          } finally {
                                            if (mounted)
                                              setState(
                                                () => _isLoading = false,
                                              );
                                          }
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                      : const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 16,
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Loginscreen(),
                            ),
                          ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: kSecondaryAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
