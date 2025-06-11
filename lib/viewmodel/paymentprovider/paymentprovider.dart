import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Paymentprovider with ChangeNotifier {
  late Razorpay _razorpay;

  void initializerazorpay({
    required BuildContext context,
    required double amount,
    required String reqstId,
    required String jobId,
    required String providerId,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (response) =>
          _handleSuccess(context, response, reqstId, jobId, providerId),
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (response) => _handlefailure(context, response),
    );
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (response) => _handleExternalwallet(context, response),
    );
    _startPayment(amount);
  }

  void _startPayment(double amount) {
    var options = {
      'Key': 'rzp_test_k6zYXVnW8obUew',
      'amount': amount,
      'name': "Svareign",
      'description': "Service Payment",
      'profile': {
        'contact number': FirebaseAuth.instance.currentUser?.phoneNumber,
      },
      'external': {
        'wallets': ['paytm'],
      },
    };
    try {} catch (e) {
      debugPrint("Razorpay error :$e");
    }
  }

  void _handleSuccess(
    BuildContext context,
    PaymentSuccessResponse response,
    String reqstId,
    String jobId,
    String providerId,
  ) async {
    final userid = FirebaseAuth.instance.currentUser?.uid;
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment successfull"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlefailure(BuildContext context, PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("payment failed :${response.message}")),
    );
  }

  void _handleExternalwallet(
    BuildContext context,
    ExternalWalletResponse response,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Externalwallet selected :${response.walletName}"),
      ),
    );
  }

  void disposerazopay() {
    _razorpay.clear();
  }
}
