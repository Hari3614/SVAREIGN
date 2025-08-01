import 'package:flutter/material.dart';

class Paymentsuccesscreen extends StatelessWidget {
  const Paymentsuccesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment Successfull')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text('Payment Completed', style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Go to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
