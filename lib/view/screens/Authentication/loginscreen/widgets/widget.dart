import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:svareign/provider/authprovider/authprovider.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/utils/elevatedbutton/elevatedbutton.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/view/screens/Authentication/roleselectionpage/role_selection_page.dart';
import 'package:svareign/view/screens/Authentication/signupscreen/signupscreen.dart';

class Loginwidget extends StatelessWidget {
  const Loginwidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phonenumbercontroller = TextEditingController();
    final TextEditingController passwordcontroller = TextEditingController();

    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: height * 0.35,
            width: width * 10,
            child: Image.asset('assets/images/app icon1.png'),
          ),

          Text(
            'Welcome Back!',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: height * 0.06),

          Textfieldwidget(
            inputType: TextInputType.number,
            controller: phonenumbercontroller,
            labeltext: 'Mobile number',
            obscuretext: false,
            preffixicon: Icons.email,
            color: kblackcolor,
            hinttext: 'Enter Mobile Number',
          ),
          SizedBox(height: 40),
          Textfieldwidget(
            controller: passwordcontroller,
            labeltext: "Password",
            hinttext: "Enter Password",
            obscuretext: true,
            preffixicon: Icons.fingerprint,
            color: kblackcolor,
            suffixicon: Icons.remove_red_eye,
          ),
          SizedBox(height: 40),
          Elevatedbuttonwidget(
            onpressed: () {
              final phone = phonenumbercontroller.text.trim();
              final password = passwordcontroller.text.trim();
              if (phone.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please fill all the fields")),
                );
              } else {
                context.read<Authprovider>().loginwithphoneandpassword(
                  phone: phone,
                  password: password,
                  context: context,
                );
              }
            },
            widht: width * 0.4,
            height: height * 0.054,
            color: Colors.black26,
            buttontext: 'Login',
            textsize: 16,
          ),
          SizedBox(height: 30),
          Text(
            "Did'nt have an account ?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () {
              showroleselectionpage(context);
            },
            child: Text(
              'SignUp',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showroleselectionpage(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
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
              Row(
                children: [
                  const Text(
                    'Select your Role',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text(
                                'Role Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🛠 Service Provider: Offers services like plumbing, electrical work, etc.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '👤 Customer: Can browse and book service providers.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },

                    child: const Icon(Icons.info_outline, color: Colors.black),
                  ),
                ],
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
                    title: 'Customer',
                    imagpath: 'assets/images/app icon1.png',
                    ontap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signupscreen()),
                      );
                    },
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
