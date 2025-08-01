import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:svareign/view/screens/customerscreen/paymentsucess/paymentsucces.dart';
import 'package:upi_pay/upi_pay.dart';
import 'package:uuid/uuid.dart';

class Upiredirectprovider with ChangeNotifier {
  bool _ispaymentlaunched = false;
  bool get isPaymentlaunched => _ispaymentlaunched;
  UpiPay upiPay = UpiPay();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<void> launchupiapp({
    required String userId,
    required String upiId,
    required String name,
    required double amount,
    required BuildContext context,
    required String providerId,
    //  required String txnNote,
  }) async {
    _ispaymentlaunched = true;
    notifyListeners();
    try {
      final apps = await upiPay.getInstalledUpiApplications();
      if (apps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("No Upi App found on these device"),
          ),
        );
        _ispaymentlaunched = false;
        notifyListeners();
        return;
      }
      final selectedapp = apps.firstWhere(
        (app) => app.upiApplication == UpiApplication.googlePay,
        orElse: () => apps.first,
      );
      final transactionref = "TXN${DateTime.now().millisecondsSinceEpoch}";
      final result = await upiPay.initiateTransaction(
        app: selectedapp.upiApplication,
        receiverUpiAddress: upiId,
        receiverName: name,
        transactionRef: transactionref,
        amount: amount.toStringAsFixed(2),
      );
      debugPrint('Transaction Status: ${result.status}');
      //debugPrint('Transaction ID: ${result.transactionId}');

      if (result.status == UpiTransactionStatus.success) {
        await savepaymenttofirestore(
          providerId: providerId,
          userId: userId,
          upiId: upiId,
          name: name,
          amount: amount,
          transactionref: transactionref,
          transactionId: result.txnId!,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Paymentsuccesscreen()),
        );
      } else if (result.status == UpiTransactionStatus.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Transaction Failed ")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Transaction Cancelled ")));
      }
    } catch (E) {
      _ispaymentlaunched = false;
      notifyListeners();
      debugPrint('Upi launched error :$E');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to launch UPI app: $E")));
    }
    _ispaymentlaunched = false;
    notifyListeners();
  }

  void resetpaymentstatus() {
    _ispaymentlaunched = false;
    notifyListeners();
  }

  Future<void> savepaymenttofirestore({
    required String userId,
    required String upiId,
    required String name,
    required double amount,
    required String transactionref,
    required String transactionId,
    required String providerId,
  }) async {
    final paymentId = Uuid().v4();
    final paymentdata = {
      'paymentId': paymentId,
      'userId': userId,
      'providerId': providerId,
      'upiId': upiId,
      'name': name,
      'amount': amount,
      'transactionref': transactionref,
      'trnasactionId': transactionId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('payments')
        .doc(paymentId)
        .set(paymentdata);
    // save prvoider side
    await _firebaseFirestore
        .collection('services')
        .doc(providerId)
        .collection('payments')
        .doc(paymentId)
        .set(paymentdata);
  }
}
