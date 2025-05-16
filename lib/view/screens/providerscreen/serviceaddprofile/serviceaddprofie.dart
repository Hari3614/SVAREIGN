import 'package:flutter/material.dart';
import 'package:svareign/view/screens/providerscreen/serviceaddprofile/widgets/addprofilewidget.dart';

class Serviceaddprofie extends StatelessWidget {
  const Serviceaddprofie({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "Setup Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        // backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(child: Addprofilewidget()),
    );
  }
}
