import 'package:flutter/material.dart';
import 'package:svareign/view/screens/Authentication/loginscreen/widgets/widget.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: Loginwidget()));
  }
}
