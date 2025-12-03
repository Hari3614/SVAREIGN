const { onSchedule } = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// 🔹 Function: Automatically delete works older than 24 hours
exports.deleteExpiredWorks = onSchedule("every 24 hours", async (event) => {
  try {
    const now = admin.firestore.Timestamp.now();
    const cutoff = new Date(now.toDate().getTime() - 24 * 60 * 60 * 1000); // 24 hours ago

    const worksSnapshot = await db.collection("works")
      .where("postedtime", "<=", cutoff)
      .get();

    if (worksSnapshot.empty) {
      logger.info("No expired works found.");
      return;
    }

    const batch = db.batch();

    worksSnapshot.forEach((doc) => {
      const workData = doc.data();

      // Delete from global "works" collection
      batch.delete(doc.ref);

      // Delete from user’s subcollection
      const userWorkRef = db
        .collection("users")
        .doc(workData.userId)
        .collection("works")
        .doc(doc.id);
      batch.delete(userWorkRef);
    });

    await batch.commit();
    logger.info(`${worksSnapshot.size} expired works deleted successfully.`);
  } catch (error) {
    logger.error("Error deleting expired works:", error);
  }
});
