import 'package:flutter/material.dart';

class Serviceproviders extends StatelessWidget {
  const Serviceproviders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_sharp, size: 50, color: Colors.black38),
            SizedBox(height: 20),
            Text(
              "No Service Provider In Your location",
              style: TextStyle(color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}
