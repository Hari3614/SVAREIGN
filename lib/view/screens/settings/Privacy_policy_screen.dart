import 'package:flutter/material.dart';

/// ------------------- Privacy Policy Screen -------------------
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            '''
Privacy Policy for Svareign  
Effective Date: 16-08-2025  

Svareign (“we,” “our,” or “us”) values your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our home service application.

1. Information We Collect  
- Personal Information: name, phone number, email address, login details.  
- Location Information: device’s location (with permission).  
- Usage Data: device type, OS, app version, logs.  

2. How We Use Your Information  
- To provide and improve services.  
- To connect you with service providers.  
- To personalize your experience.  
- To communicate updates, promotions, notifications.  
- To comply with legal requirements.  

3. Sharing of Information  
- With Service Providers.  
- With third-party tools (analytics/crash reporting).  
- When required by law.  

4. Location Data  
- Suggest relevant services near you.  
- Help providers find your location.  

5. Data Security  
We use security measures to protect your data.  

6. Your Rights  
You can access, update, or delete your data.  

7. Children’s Privacy  
We do not collect information from children under 13.  

8. Changes  
We may update this Privacy Policy with a new date.  

9. Contact Us  
📧 teamsvareign@gmail.com  
            ''',
            style: TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
