// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// Future<void> saveFcmtoken(String providerId) async {
//   final token = await FirebaseMessaging.instance.getToken();
//   if (token != null) {
//     await FirebaseFirestore.instance.collection('services').doc(providerId).set(
//       {'fcmToken': token},
//       SetOptions(merge: true),
//     );
//     print("save fcm token succesfully");
//   } else {
//     print('failed to get fcm token');
//   }
// }

// void setupTokenRefreshListener(String uid) {
//   FirebaseMessaging.instance.onTokenRefresh.listen((newtoken) async {
//     await saveFcmtoken(uid);
//   });
// }
