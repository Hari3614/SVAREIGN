import 'package:flutter/material.dart';

/// ------------------- Customer Agreements Screen -------------------
class CustomerAgreementsScreen extends StatelessWidget {
  const CustomerAgreementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Customer Agreement",
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
            'Customer Agreement (Terms of Service)\n\n'
            'Welcome to Svareign. This Customer Agreement ("Agreement") governs your access to and use of the Svareign mobile application (the "App" or "Platform"). By creating an account or using Svareign, you agree to be bound by this Agreement. If you do not agree, please do not use the Platform.\n\n'
            '1. Overview of the Platform\n\n'
            'Svareign is a hyperlocal marketplace that connects individuals seeking local services ("Users") with independent service providers ("Providers") for tasks such as home repairs, skilled trade work, and custom local tasks. Svareign does not employ Providers and does not directly perform any services listed on the Platform. Svareign acts solely as a facilitator connecting Users and Providers.\n\n'
            '2. Eligibility\n\n'
            'You must be at least 18 years of age to create an account or use the Platform, whether as a User or a Provider. By using Svareign, you confirm that you meet this requirement and that all information you provide is accurate and current.\n\n'
            '3. Account Responsibility\n\n'
            'You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account. You agree to notify us immediately of any unauthorized use of your account.\n\n'
            '4. Nature of the Platform\n\n'
            'Svareign currently operates as an open listing platform. Providers are not currently subject to formal background verification or credential checks. Users are encouraged to exercise their own judgment, ask questions, and take reasonable precautions when engaging a Provider. Svareign intends to introduce Provider verification processes in the future, and this Agreement will be updated accordingly when such measures are implemented.\n\n'
            '5. Role of Svareign and Limitation of Liability\n\n'
            'Svareign is a connector between Users and Providers and is not a party to any agreement, transaction, or service arrangement made between them. Svareign does not guarantee the quality, safety, legality, timeliness, or outcome of any service performed by a Provider, nor the conduct, reliability, or intentions of any User or Provider.\n\n'
            'To the maximum extent permitted by law, Svareign is not liable for any direct, indirect, incidental, or consequential damages, losses, disputes, property damage, personal injury, or financial loss arising from interactions, transactions, or services facilitated through the Platform.\n\n'
            'While Svareign does not assume legal liability for disputes between Users and Providers, we are committed to maintaining a trustworthy Platform. If you report a concern, issue, or violation involving another user, Svareign may, at its discretion, investigate and take appropriate action against the relevant account, including warnings, suspension, or permanent removal from the Platform.\n\n'
            '6. Payments\n\n'
            'Svareign intends to integrate a secure third-party payment processing system within the App to facilitate transactions between Users and Providers. Once implemented, payments made through this system will be subject to the terms and security standards of the relevant payment processor, in addition to this Agreement.\n\n'
            'Until such integration is complete, any payments, fees, or compensation arrangements made between Users and Providers occur directly between those parties, outside the Platform. Svareign is not responsible for the handling, security, or outcome of any such direct payments made outside the App.\n\n'
            'Svareign does not charge commission on services arranged through the Platform.\n\n'
            '7. Custom Tasks and User-Generated Content\n\n'
            'Users may post custom tasks, including descriptions and photos, to communicate task requirements to potential Providers. You agree not to post any content that is unlawful, abusive, fraudulent, sexually explicit, harassing, or that violates the rights of any third party.\n\n'
            'Svareign reserves the right to remove any content or task that violates this Agreement without prior notice.\n\n'
            '8. User Conduct\n\n'
            'You agree to use the Platform respectfully and lawfully. You agree not to:\n\n'
            '\u2022 Harass, threaten, defraud, or harm other Users or Providers\n'
            '\u2022 Use the Platform for any illegal purpose\n'
            '\u2022 Misrepresent your identity, qualifications, or intentions\n'
            '\u2022 Attempt to circumvent the Platform\'s safety, verification, or reporting mechanisms once implemented\n\n'
            'Violation of this section may result in suspension or termination of your account.\n\n'
            '9. Reporting and Account Actions\n\n'
            'If a User or Provider engages in conduct that violates this Agreement or otherwise compromises the safety or integrity of the Platform, Svareign reserves the right to investigate the matter and take action on the relevant account, including warnings, temporary suspension, or permanent termination, at its sole discretion.\n\n'
            '10. Termination\n\n'
            'Svareign reserves the right to suspend or terminate any account, at its discretion, for violation of this Agreement, fraudulent activity, or conduct that endangers other Users, Providers, or the integrity of the Platform. Users may also delete their account at any time.\n\n'
            '11. Changes to This Agreement\n\n'
            'Svareign may update this Agreement from time to time, particularly as new features (such as Provider verification or in-app payments) are introduced. Continued use of the Platform after changes are made constitutes acceptance of the updated Agreement. Material changes will be communicated through the App.\n\n'
            '12. Governing Law\n\n'
            'This Agreement is governed by the laws of India. Any disputes arising from or related to this Agreement shall be subject to the exclusive jurisdiction of the courts in Hyderabad, Telangana.\n\n'
            '13. Contact Us\n\n'
            'For questions, concerns, or complaints regarding this Agreement, please contact us at:\n\n'
            'Email: support@svareign.com\n'
            'App: Svareign\n\n'
            'By using Svareign, you acknowledge that you have read, understood, and agree to be bound by this Customer Agreement.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ),
    );
  }
}
