import 'package:flutter/material.dart';

class CustomreqstScreen extends StatelessWidget {
  const CustomreqstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Screen")),
      body: Center(child: Text("No requests Found")),
    );
  }
}
