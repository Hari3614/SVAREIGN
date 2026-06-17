import 'package:flutter/material.dart';

/// ------------------- Customer Agreements Screen -------------------
class CustomerAgreementsScreen extends StatelessWidget {
  const CustomerAgreementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Customer Agreements",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text('''
Customer Agreements  

1. Users must provide accurate details while booking services.  
2. Cancellations must be done at least 2 hours before service time.  
3. Service providers are independent contractors, not employees of Svareign.  
4. Payments should be completed securely via the app.  
5. Any disputes will be handled under the laws of your country.  

By using Svareign, you agree to these terms.  
            ''', style: TextStyle(fontSize: 15, height: 1.6)),
        ),
      ),
    );
  }
}
