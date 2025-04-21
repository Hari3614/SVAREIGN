import 'package:flutter/material.dart';
import 'package:svareign/core/colors/app_theme_color.dart';
import 'package:svareign/utils/elevatedbutton/elevatedbutton.dart';
import 'package:svareign/utils/textformfield/textfieldwidget.dart';

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
          // SizedBox(height: 10),
          Text(
            'Welcome Back!',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: height * 0.06),
          // Text("Log in to your account using\nmobile number"),
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
            suffixicon: Icons.remove_red_eye,
          ),
          SizedBox(height: 40),
          Elevatedbuttonwidget(
            onpressed: () {},
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
            onPressed: () {},
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
}
