import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/viewmodel/authprovider/customer/authprovider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/utils/elevatedbutton/elevatedbutton.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/viewmodel/passwordvisiblity/password_visiblity_provider.dart';
import 'package:svareign/viewmodel/signupformprovider/form_provider.dart';

class Signupwidget extends StatelessWidget {
  Signupwidget({super.key});

  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController emailcontroller = TextEditingController();
  final TextEditingController phonecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController confirmcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.24,
              width: width * 1,
              child: Image.asset('assets/images/app icon1.png'),
            ),
            Text(
              'Create New Account',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 30),

            // Name
            Textfieldwidget(
              controller: namecontroller,
              labeltext: 'Name',
              hinttext: 'Enter Name',
              color: kblackcolor,
              preffixicon: Icons.person,
              obscuretext: false,

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              onchanged: (value) {
                Provider.of<Signupformprovide>(
                  context,
                  listen: false,
                ).updatefield('name', value!);
                return null;
              },
            ),
            SizedBox(height: 30),

            // Email
            Textfieldwidget(
              controller: emailcontroller,
              labeltext: 'E-mail',
              hinttext: 'Enter your e-mail address',
              color: kblackcolor,
              preffixicon: Icons.email,
              obscuretext: false,
              // errortext: "please",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
              onchanged: (value) {
                Provider.of<Signupformprovide>(
                  context,
                  listen: false,
                ).updatefield('email', value!);
                return null;
              },
            ),
            SizedBox(height: 30),

            // Phone
            Textfieldwidget(
              controller: phonecontroller,
              labeltext: 'Mobile Number',
              hinttext: 'Enter the Mobile Number',
              color: kblackcolor,
              preffixicon: Icons.phone,
              obscuretext: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your phone number';
                } else if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              },
              onchanged: (value) {
                Provider.of<Signupformprovide>(
                  context,
                  listen: false,
                ).updatefield("phone", value!);
                return null;
              },
            ),
            SizedBox(height: 30),

            // Password
            Consumer<PasswordVisiblityProvider>(
              builder: (context, visiblityprovider, child) {
                return Textfieldwidget(
                  controller: passwordcontroller,
                  labeltext: 'Password',
                  hinttext: 'Enter the Password',
                  color: kblackcolor,
                  preffixicon: Icons.password,
                  obscuretext: visiblityprovider.isobscured,
                  suffixicon: IconButton(
                    onPressed: () {
                      visiblityprovider.togglevisiblity();
                    },
                    icon: Icon(
                      visiblityprovider.isobscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onchanged: (value) {
                    Provider.of<Signupformprovide>(
                      context,
                      listen: false,
                    ).updatefield("password", value!);
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 30),

            // Confirm Password
            Consumer<PasswordVisiblityProvider>(
              builder: (context, visiblity, child) {
                return Textfieldwidget(
                  controller: confirmcontroller,
                  labeltext: 'Confirm Password',
                  hinttext: 'Re-enter the Password',
                  color: kblackcolor,
                  preffixicon: Icons.fingerprint,
                  obscuretext: visiblity.isobscured,
                  suffixicon: IconButton(
                    onPressed: () {
                      visiblity.togglevisiblity();
                    },
                    icon: Icon(
                      visiblity.isobscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  validator: (value) {
                    if (value != passwordcontroller.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onchanged: (value) {
                    Provider.of<Signupformprovide>(
                      listen: false,
                      context,
                    ).updatefield("confirmpassword", value!);
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 30),

            // Signup Button
            Consumer<Signupformprovide>(
              builder: (context, signupprovider, child) {
                return Elevatedbuttonwidget(
                  onpressed: () {
                    if (namecontroller.text.isEmpty ||
                        emailcontroller.text.isEmpty ||
                        phonecontroller.text.isEmpty ||
                        passwordcontroller.text.isEmpty ||
                        confirmcontroller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('All fields are required')),
                      );
                    } else if (_formKey.currentState!.validate()) {
                      final authProvider = Provider.of<Authprovider>(
                        context,
                        listen: false,
                      );

                      authProvider.sendotp(
                        name: namecontroller.text.trim(),
                        email: emailcontroller.text.trim(),
                        phonenumber: phonecontroller.text.trim(),
                        password: passwordcontroller.text.trim(),
                        context: context,
                      );
                    }
                  },
                  widht: width * 0.4,
                  height: height * 0.054,
                  color:
                      signupprovider.areAllFieldsFilled
                          ? Colors.black
                          : Colors.grey,
                  textsize: 16,
                  buttontext: 'Signup',
                );
              },
            ),
            SizedBox(height: 10),

            // Already have an account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account ?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Loginscreen()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
