import 'package:flutter/material.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/utils/elevatedbutton/elevatedbutton.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/loginscreen.dart';
import 'package:svareign/view/screens/Authentication/otpscreen/otp_screen.dart';

class Signupwidget extends StatelessWidget {
  const Signupwidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController namecontroller = TextEditingController();
    final TextEditingController emailcontroller = TextEditingController();
    final TextEditingController phonecontroller = TextEditingController();
    final TextEditingController passwordcontroller = TextEditingController();
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    return SingleChildScrollView(
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
          Textfieldwidget(
            controller: namecontroller,
            labeltext: 'Name',
            hinttext: 'Enter Name',
            color: kblackcolor,
            preffixicon: Icons.person,

            obscuretext: false,
          ),
          SizedBox(height: 30),
          Textfieldwidget(
            controller: namecontroller,
            color: kblackcolor,
            labeltext: 'E-mail',
            hinttext: 'Enter your e-mail address',
            preffixicon: Icons.email,
            obscuretext: false,
          ),
          SizedBox(height: 30),
          Textfieldwidget(
            controller: namecontroller,
            color: kblackcolor,
            labeltext: 'Mobile Number',
            hinttext: 'Enter the Mobile Number',
            preffixicon: Icons.phone,
            obscuretext: false,
          ),
          SizedBox(height: 30),
          Textfieldwidget(
            controller: namecontroller,
            labeltext: 'Password',
            color: kblackcolor,
            hinttext: 'Enter the Password',
            preffixicon: Icons.password,
            obscuretext: false,
          ),
          SizedBox(height: 30),
          Textfieldwidget(
            controller: namecontroller,
            labeltext: 'Confirm Password',
            hinttext: 'Re-enter the Password',
            color: kblackcolor,
            preffixicon: Icons.fingerprint,
            obscuretext: false,
          ),
          SizedBox(height: 30),
          Elevatedbuttonwidget(
            onpressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OtpScreen()),
              );
            },
            widht: width * 0.4,
            height: height * 0.054,
            color: kgreycolor,
            textsize: 16,
            buttontext: 'Signup',
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account ?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
