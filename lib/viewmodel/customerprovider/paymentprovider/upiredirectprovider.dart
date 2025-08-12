// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:uuid/uuid.dart';

// class Upiredirectprovider with ChangeNotifier {
//   bool _ispaymentlaunched = false;
//   bool get isPaymentlaunched => _ispaymentlaunched;

//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

//   Future<void> launchupiapp({
//     required String userId,
//     required String upiId,
//     required String name,
//     required double amount,
//     required BuildContext context,
//     required String providerId,
//   }) async {
//     _ispaymentlaunched = true;
//     notifyListeners();

//     try {
//       final transactionRef = "TXN${DateTime.now().millisecondsSinceEpoch}";
//       final upiUrl = Uri.parse(
//         "upi://pay?pa=$upiId&pn=$name&tn=Service Payment&am=${amount.toStringAsFixed(2)}&cu=INR&tr=$transactionRef",
//       );

//       if (await canLaunchUrl(upiUrl)) {
//         // Save transaction BEFORE launching UPI app
//         await savepaymenttofirestore(
//           providerId: providerId,
//           userId: userId,
//           upiId: upiId,
//           name: name,
//           amount: amount,
//           transactionref: transactionRef,
//         );

//         await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
//         // Optional: Navigate to success screen directly if you trust intent only
//         // Navigator.push(context, MaterialPageRoute(builder: (context) => Paymentsuccesscreen()));
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("No UPI app found or unable to launch"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('UPI deep link launch error: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to launch UPI app: $e")));
//     }

//     _ispaymentlaunched = false;
//     notifyListeners();
//   }

//   void resetpaymentstatus() {
//     _ispaymentlaunched = false;
//     notifyListeners();
//   }

//   Future<void> savepaymenttofirestore({
//     required String userId,
//     required String upiId,
//     required String name,
//     required double amount,
//     required String transactionref,
//     required String providerId,
//   }) async {
//     final paymentId = const Uuid().v4();
//     final paymentdata = {
//       'paymentId': paymentId,
//       'userId': userId,
//       'providerId': providerId,
//       'upiId': upiId,
//       'name': name,
//       'amount': amount,
//       'transactionref': transactionref,
//       'status': 'initiated', // No way to confirm actual result
//       'timestamp': FieldValue.serverTimestamp(),
//     };

//     await _firebaseFirestore
//         .collection('users')
//         .doc(userId)
//         .collection('payments')
//         .doc(paymentId)
//         .set(paymentdata);

//     await _firebaseFirestore
//         .collection('services')
//         .doc(providerId)
//         .collection('payments')
//         .doc(paymentId)
//         .set(paymentdata);
//   }
// }
