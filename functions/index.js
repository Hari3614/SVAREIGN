const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

/**
 * Scheduled Cloud Function: runs every hour.
 * Deletes customer task posts (in /works and /users/{uid}/works) that have expired (older than 24 hours).
 */
exports.deleteExpiredWorks = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    // Query all expired works from the global /works collection
    const expiredSnapshot = await db
      .collection('works')
      .where('expirytime', '<=', now)
      .get();

    if (expiredSnapshot.empty) {
      console.log('No expired works found.');
      return null;
    }

    const batch = db.batch();

    for (const doc of expiredSnapshot.docs) {
      const data = doc.data();
      const userId = data.userId;

      // Delete from global /works collection
      batch.delete(doc.ref);

      // Also delete from user's subcollection
      if (userId) {
        const userWorkRef = db
          .collection('users')
          .doc(userId)
          .collection('works')
          .doc(doc.id);
        batch.delete(userWorkRef);
      }
    }

    await batch.commit();
    console.log(`Deleted ${expiredSnapshot.size} expired work(s).`);
    return null;
  });
