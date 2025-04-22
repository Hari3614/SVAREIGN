import 'package:flutter/material.dart';
import 'package:svareign/view/screens/Authentication/signupscreen/widgets/signupwidget.dart';

class Signupscreen extends StatelessWidget {
  const Signupscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Signupwidget()));
  }
}
