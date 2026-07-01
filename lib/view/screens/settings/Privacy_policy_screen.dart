import 'package:flutter/material.dart';

/// ------------------- Privacy Policy Screen -------------------
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
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
          child: const Text(
            'Privacy Policy\n\n'
            'Welcome to Svareign ("we," "our," "us," or the "Platform"). This Privacy Policy explains how we collect, use, store, and protect your information when you use the Svareign mobile application (the "App"). By creating an account or using the App, you agree to the practices described in this policy.\n\n'
            'Svareign is operated in India and provides this Privacy Policy in accordance with applicable Indian data protection law.\n\n'
            '1. Information We Collect\n\n'
            'We collect the following categories of personal information directly from you when you register and use the App:\n\n'
            '\u2022 Name \u2014 to identify your account and display your profile to other users (e.g., service providers or task posters).\n\n'
            '\u2022 Phone Number \u2014 used for account verification, login, and communication related to services or tasks.\n\n'
            '\u2022 Location Data \u2014 used to connect you with nearby service providers or relevant local tasks. Location is collected only while the App is in use or as permitted by your device settings.\n\n'
            '\u2022 Photos (Custom Tasks) \u2014 if you post a custom task, you may upload photos to describe the task. These images are stored on our cloud infrastructure (Firebase Storage) and are not actively viewed, reviewed, or accessed by Svareign staff as part of normal operations. They exist as part of the task record solely for the purpose of communicating task details to relevant service providers.\n\n'
            'We may collect additional categories of information in the future as the Platform evolves. This Privacy Policy will be updated accordingly, and you will be notified of any material changes.\n\n'
            '2. How We Use Your Information\n\n'
            'We use the information collected solely to operate and improve the Platform, including to:\n\n'
            '\u2022 Create and manage your account\n'
            '\u2022 Connect you with relevant service providers or task opportunities in your area\n'
            '\u2022 Facilitate communication between users and providers\n'
            '\u2022 Maintain the safety, security, and integrity of the Platform\n'
            '\u2022 Improve App performance and user experience\n'
            '\u2022 Comply with applicable legal obligations\n\n'
            'We do not sell your personal information to third parties.\n\n'
            '3. Third-Party Service Providers\n\n'
            'We may use trusted third-party infrastructure and service providers to help operate the App, such as cloud hosting, authentication, and analytics services. These providers process data strictly on our behalf and in accordance with industry-standard privacy and security practices. We do not sell or share your data with third parties for their own marketing purposes.\n\n'
            '4. Data Storage and Security\n\n'
            'Your data is stored using Firebase\'s cloud infrastructure, which includes industry-standard security measures such as encryption in transit. While we take reasonable steps to protect your information, no method of electronic storage or transmission is 100% secure, and we cannot guarantee absolute security.\n\n'
            '5. Data Retention\n\n'
            'We retain your personal information for as long as your account remains active. If you request account deletion, we will delete or anonymize your personal data within a reasonable timeframe, except where retention is required to comply with legal obligations, resolve disputes, or enforce our agreements.\n\n'
            '6. Your Rights\n\n'
            'In accordance with India\'s Digital Personal Data Protection Act, 2023 (DPDP Act), you have the right to:\n\n'
            '\u2022 Access the personal data we hold about you\n'
            '\u2022 Request correction of inaccurate or incomplete data\n'
            '\u2022 Request deletion of your personal data\n'
            '\u2022 Withdraw consent to data processing at any time (which may limit your ability to use certain features of the App)\n'
            '\u2022 Raise grievances regarding the handling of your data\n\n'
            'To exercise any of these rights, you may contact us at support@svareign.com.\n\n'
            '7. Age Requirement\n\n'
            'You must be at least 18 years of age to create an account or use Svareign. By registering, you confirm that you meet this requirement. Svareign does not knowingly collect personal information from individuals under 18. If we become aware that a user under 18 has created an account, we will take steps to delete that account and associated data.\n\n'
            'Note: Tasks posted on the Platform (e.g., tutoring, babysitting, gardening) may relate to services involving minors as beneficiaries, but the person creating the account, posting the task, or providing the service must themselves be 18 or older.\n\n'
            '8. Children\'s Privacy\n\n'
            'Svareign is not directed at children under 18, and we do not knowingly collect data from them. If you believe a minor has provided us with personal information, please contact us so we can take appropriate action.\n\n'
            '9. Changes to This Policy\n\n'
            'We may update this Privacy Policy from time to time, particularly as Svareign completes business registration and introduces new features (such as payments or identity verification). We will notify users of material changes through the App or via the contact information provided.\n\n'
            '10. Contact Us\n\n'
            'If you have questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact us at:\n\n'
            'Email: support@svareign.com\n'
            'App: Svareign\n\n'
            '11. Governing Law\n\n'
            'This Privacy Policy is governed by the laws of India. Any disputes arising from or related to this Policy shall be subject to the exclusive jurisdiction of the courts in Hyderabad, Telangana.\n\n'
            'This Privacy Policy is intended to comply with applicable Indian data protection law, including the Digital Personal Data Protection Act, 2023.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ),
    );
  }
}
