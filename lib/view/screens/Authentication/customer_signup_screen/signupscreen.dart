import 'package:flutter/material.dart';
import 'package:svareign/view/screens/Authentication/customer_signup_screen/widgets/signupwidget.dart';

class Signupscreen extends StatelessWidget {
  final String usertype;
  const Signupscreen({super.key, required this.usertype});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Signupwidget()));
  }
}
