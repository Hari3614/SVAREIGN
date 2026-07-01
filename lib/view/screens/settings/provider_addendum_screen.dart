import 'package:flutter/material.dart';

/// ------------------- Provider Addendum Screen -------------------
class ProviderAddendumScreen extends StatelessWidget {
  const ProviderAddendumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Provider Addendum",
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
            'Provider Addendum\n\n'
            'This Provider Addendum ("Addendum") supplements the Svareign Customer Agreement and applies specifically to individuals or businesses who register on Svareign as a Provider to offer services through the Platform. By registering as a Provider, you agree to this Addendum in addition to the general Customer Agreement.\n\n'
            '1. Independent Contractor Status\n\n'
            'You acknowledge and agree that you are registering as an independent, self-employed service provider. Nothing in this Addendum or your use of the Platform creates an employment, partnership, agency, or joint venture relationship between you and Svareign. Svareign does not direct, supervise, or control the manner in which you perform any service, and you are solely responsible for how you carry out your work.\n\n'
            '2. Your Responsibilities as a Provider\n\n'
            'As a Provider, you are solely responsible for:\n\n'
            '\u2022 Holding any licenses, certifications, permits, insurance, or qualifications legally required to perform the services you offer\n'
            '\u2022 Using appropriate tools, equipment, and safety practices while performing services\n'
            '\u2022 Complying with all applicable local, state, and national laws relevant to your trade or service\n'
            '\u2022 The quality, safety, and outcome of the work you perform\n'
            '\u2022 Any taxes, fees, or financial obligations arising from your work, including income earned through the Platform\n\n'
            'Svareign does not verify licenses, qualifications, or insurance at this time. You represent that you possess any qualifications necessary to safely and lawfully perform the services you list.\n\n'
            '3. No Employment Benefits\n\n'
            'As an independent contractor, you are not entitled to any employment benefits from Svareign, including but not limited to minimum wage guarantees, paid leave, insurance coverage, retirement benefits, or workers\' compensation. You are responsible for your own insurance coverage relevant to your work.\n\n'
            '4. Liability and Indemnification\n\n'
            'You agree that you are solely responsible for any injury, property damage, loss, or claim arising from the services you provide to Users. You agree to indemnify and hold harmless Svareign, its founders, and any associated personnel from any claims, damages, losses, or legal costs arising out of:\n\n'
            '\u2022 Your performance or non-performance of any service\n'
            '\u2022 Any injury or property damage caused during or as a result of your work\n'
            '\u2022 Any dispute between you and a User regarding the service provided\n'
            '\u2022 Your violation of any law, regulation, or third-party right while using the Platform\n\n'
            'Svareign is not a party to the service arrangement between you and any User and bears no responsibility for the outcome of the work performed.\n\n'
            '5. Conduct While Performing Services\n\n'
            'When performing services arranged through Svareign, you agree to:\n\n'
            '\u2022 Conduct yourself professionally and respectfully toward Users\n'
            '\u2022 Only perform the service agreed upon and disclosed through the Platform\n'
            '\u2022 Not engage in any unsafe, fraudulent, deceptive, or harmful conduct toward Users or their property\n'
            '\u2022 Immediately report any safety concerns or incidents to Svareign\n\n'
            'Violation of this section may result in suspension or permanent removal from the Platform, in addition to any other legal consequences.\n\n'
            '6. Future Verification Requirements\n\n'
            'Svareign intends to introduce Provider verification, background checks, and/or credentialing requirements in the future. Once implemented, continued use of the Platform as a Provider may be conditioned on completing such verification. This Addendum will be updated accordingly at that time.\n\n'
            '7. Payments\n\n'
            'Until Svareign\'s in-app payment system is live, payment for services is arranged directly between you and the User, outside the Platform. You are solely responsible for agreeing on payment terms with the User and for collecting payment. Svareign is not responsible for any non-payment, late payment, or payment disputes occurring outside the Platform.\n\n'
            'Svareign does not currently charge any commission on services arranged through the Platform.\n\n'
            '8. Termination\n\n'
            'Svareign reserves the right to suspend or permanently remove your Provider account at its discretion, including for violation of this Addendum, complaints from Users, unsafe conduct, or fraudulent activity.\n\n'
            '9. Governing Law\n\n'
            'This Addendum is governed by the laws of India, with disputes subject to the exclusive jurisdiction of the courts in Hyderabad, Telangana.\n\n'
            '10. Contact Us\n\n'
            'For questions regarding this Addendum, contact us at:\n\n'
            'Email: support@svareign.com\n'
            'App: Svareign\n\n'
            'By registering as a Provider on Svareign, you acknowledge that you have read, understood, and agree to be bound by this Provider Addendum in addition to the Svareign Customer Agreement.',
            style: TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
      ),
    );
  }
}
