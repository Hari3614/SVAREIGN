import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/viewmodel/authprovider/serviceprovider/service_authprovider.dart';
import 'package:svareign/utils/elevatedbutton/elevatedbutton.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/viewmodel/passwordvisiblity/password_visiblity_provider.dart';
import 'package:svareign/viewmodel/signupformprovider/form_provider.dart';

class ServiceSignupWidget extends StatelessWidget {
  const ServiceSignupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController namecontroller = TextEditingController();
    final TextEditingController phonecontoller = TextEditingController();
    final TextEditingController emailcontoller = TextEditingController();
    final TextEditingController passwordcontroller = TextEditingController();
    final TextEditingController confirmcontoller = TextEditingController();
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final formkey = GlobalKey<FormState>();

    return Form(
      key: formkey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.25,
              width: width * 1,
              child: Image.asset("assets/images/app icon1.png"),
            ),
            Text(
              "Create a New Account",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 30),
            Textfieldwidget(
              controller: namecontroller,
              labeltext: "Name",
              obscuretext: false,
              preffixicon: Icons.person,
              color: kblackcolor,
              hinttext: " Enter the name",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Enter a valid Name";
                }
                return null;
              },
              onchanged: (value) {
                Provider.of<Signupformprovide>(
                  context,
                  listen: false,
                ).updatefield("name", value!);
                return null;
              },
            ),
            SizedBox(height: 30),
            Textfieldwidget(
              controller: emailcontoller,
              labeltext: "E-mail",
              obscuretext: false,
              preffixicon: Icons.email,
              color: kblackcolor,
              hinttext: "Enter the E-mail",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please Enter the E-mail";
                } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Please Enter Valid E-mail';
                }
                return null;
              },
              onchanged: (value) {
                Provider.of<Signupformprovide>(
                  listen: false,
                  context,
                ).updatefield("email", value!);

                return null;
              },
            ),
            SizedBox(height: 30),
            Textfieldwidget(
              controller: phonecontoller,
              labeltext: "Mobile Number",
              obscuretext: false,
              preffixicon: Icons.phone,
              color: kblackcolor,
              hinttext: "Enter the phone Number",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "please Enter the number";
                } else if (value.length < 10) {
                  return "please Enter a valid Phone";
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
            Consumer<PasswordVisiblityProvider>(
              builder: (context, visiblity, child) {
                return Textfieldwidget(
                  controller: passwordcontroller,
                  labeltext: "Password",
                  obscuretext: visiblity.isobscured,
                  color: kblackcolor,
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
                  preffixicon: Icons.fingerprint,
                  hinttext: "Enter the password",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter the phone number";
                    } else if (value.length < 6) {
                      return "Password must be atleast 6 characters";
                    }
                    return null;
                  },
                  onchanged: (value) {
                    Provider.of<Signupformprovide>(
                      context,
                      listen: false,
                    ).updatefield("password", value!);
                    formkey.currentState!.validate();

                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 30),
            Consumer<PasswordVisiblityProvider>(
              builder: (context, visiblity, child) {
                return Textfieldwidget(
                  controller: confirmcontoller,
                  labeltext: "Confirm Password",
                  obscuretext: visiblity.isobscured,
                  preffixicon: Icons.security,
                  suffixicon: IconButton(
                    onPressed: () {
                      visiblity.togglevisiblity();
                    },
                    icon: Icon(
                      visiblity.isobscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    color: kblackcolor,
                  ),
                  hinttext: "Verify and confirm Password",
                  validator: (value) {
                    if (value != passwordcontroller.text) {
                      return "Password does not match";
                    }
                    return null;
                  },
                  onchanged: (value) {
                    Provider.of<Signupformprovide>(
                      listen: false,
                      context,
                    ).updatefield('confirmpassword', value!);
                    formkey.currentState!.validate();
                    return null;
                  },
                );
              },
            ),
            SizedBox(height: 30),
            Consumer<Signupformprovide>(
              builder: (context, formrprovider, child) {
                return Elevatedbuttonwidget(
                  onpressed: () {
                    if (namecontroller.text.isEmpty ||
                        emailcontoller.text.isEmpty ||
                        phonecontoller.text.isEmpty ||
                        passwordcontroller.text.isEmpty ||
                        confirmcontoller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("All fields are required")),
                      );
                    } else if (formkey.currentState!.validate()) {
                      final serviceauthprovider =
                          Provider.of<ServiceAuthprovider>(
                            context,
                            listen: false,
                          );
                      serviceauthprovider.sendServiceOtp(
                        name: namecontroller.text.trim(),
                        email: emailcontoller.text.trim(),
                        phonenumber: phonecontoller.text.trim(),
                        password: passwordcontroller.text.trim(),
                        context: context,
                      );
                    }
                  },
                  widht: width * 0.35,
                  height: height * 0.05,
                  buttontext: "SignUp",
                  color:
                      formrprovider.areAllFieldsFilled
                          ? Colors.black
                          : Colors.grey,
                  textsize: 16,
                );
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account ?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
