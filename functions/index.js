// const functions = require("firebase-functions/v1"); // use v1 for 6.x
// const admin = require("firebase-admin");
// admin.initializeApp();

// exports.sendRequestAcceptedNotification = functions
//   .region("asia-south1")
//   .firestore
//   .document("requests/{requestId}")
//   .onUpdate(async (change, context) => {
//     const before = change.before.data();
//     const after = change.after.data();

//     if (before.status !== "Accepted" && after.status === "Accepted") {
//       const user = after.username || "A user";
//       const providerId = after.providerId;

//       const providerDoc = await admin.firestore().collection("services").doc(providerId).get();
//       const token = providerDoc.data()?.fcmtoken;

//       if (token) {
//         const payload = {
//           notification: {
//             title: "Request Accepted",
//             body: `${user} accepted your request`,
//           },
//         };

//         await admin.messaging().sendToDevice(token, payload);
//         functions.logger.log("✅ Notification sent to providerId:", providerId);
//       } else {
//         functions.logger.warn("⚠️ No token found for providerId:", providerId);
//       }
//     }
//   });
