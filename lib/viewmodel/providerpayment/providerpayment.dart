import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Providerpayment extends ChangeNotifier {
  late Razorpay _razorpay;

  void initializerazorpay({
    required BuildContext ctz,
    required double amount,
    required String reqstId,
    required String jobId,
    required String providerId,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (response) => _handleSuccess(ctz, response, reqstId, jobId, providerId),
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (response) => _handleFailure(ctz, response),
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (response) => _handleExternalWallet(ctz, response),
    );

    _startPayment(ctz, amount);
  }

  void _startPayment(BuildContext ctz, double amount) {
    var options = {
      'key': 'rzp_live_WgwgVz3uC8tiKg',
      'amount': (amount * 100).toInt(),
      'name': "Svareign",
      'description': "Service Payment",
      'prefill': {
        'contact': FirebaseAuth.instance.currentUser?.phoneNumber ?? '',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay open error: $e");
      ScaffoldMessenger.of(ctz).showSnackBar(
        const SnackBar(
          content: Text("Unable to start Razorpay"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSuccess(
    BuildContext ctz,
    PaymentSuccessResponse response,
    String reqstId,
    String jobId,
    String providerId,
  ) async {
    final userid = FirebaseAuth.instance.currentUser?.uid;

    try {
      await FirebaseFirestore.instance
          .collection('payments')
          .doc(response.paymentId)
          .set({
            'paymentId': response.paymentId,
            'orderId': response.orderId,
            'signature': response.signature,
            'status': "success",
            'timestamp': FieldValue.serverTimestamp(),
            'userId': userid,
            'reqstId': reqstId,
            'jobId': jobId,
            'providerId': providerId,
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .collection('requests')
          .doc(reqstId)
          .update({"paymentstatus": "paid"});

      ScaffoldMessenger.of(ctz).showSnackBar(
        const SnackBar(
          content: Text("Payment successful"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Payment success handling error: $e");
      ScaffoldMessenger.of(ctz).showSnackBar(
        const SnackBar(
          content: Text(
            "Payment succeeded, but something went wrong saving it.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _handleFailure(BuildContext ctz, PaymentFailureResponse response) {
    ScaffoldMessenger.of(ctz).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(
    BuildContext ctz,
    ExternalWalletResponse response,
  ) {
    ScaffoldMessenger.of(ctz).showSnackBar(
      SnackBar(
        content: Text("External wallet selected: ${response.walletName}"),
      ),
    );
  }

  void disposerazopay() {
    _razorpay.clear();
  }
}
