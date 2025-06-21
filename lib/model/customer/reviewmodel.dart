import 'package:cloud_firestore/cloud_firestore.dart';

class Reviewmodel {
  final String id;
  final String jobId;
  final String providerId;
  final String userid;
  final String review;
  final double rating;
  final DateTime timestamp;

  Reviewmodel({
    required this.id,
    required this.jobId,
    required this.providerId,
    required this.rating,
    required this.review,
    required this.userid,
    required this.timestamp,
  });
  factory Reviewmodel.frommap(Map<String, dynamic> map, String documentId) {
    return Reviewmodel(
      id: documentId,
      jobId: map['jobId'],
      providerId: map['providerId'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      review: map['review'],
      userid: map['userId'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  Map<String, dynamic> tomap() {
    return {
      "userId": userid,
      "providerId": providerId,
      "rating": rating,
      'review': review,
      'timestamp': timestamp,
      'jobId': jobId,
    };
  }
}
