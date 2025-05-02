import 'package:flutter/material.dart';
import 'package:svareign/view/screens/Authentication/serivice_provider/widgets/service_signup_widget.dart';

class ServiceSignupScreen extends StatelessWidget {
  final String usertype;
  const ServiceSignupScreen({super.key, required this.usertype});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: ServiceSignupWidget()));
  }
}
