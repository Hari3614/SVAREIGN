import 'package:cloud_firestore/cloud_firestore.dart';

class Jobpost {
  final String id;
  final String userId;
  final String tittle;
  final String description;
  final double minbudget;
  final double maxbudget;
  final String duration;
  final String? imagepath;
  final DateTime postedtime;

  Jobpost({
    required this.tittle,
    required this.description,
    required this.minbudget,
    required this.duration,
    this.imagepath,
    required this.postedtime,
    required this.id,
    required this.userId,
    required this.maxbudget,
  });
  factory Jobpost.fromfirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Jobpost(
      id: doc.id,
      userId: data['userId'],
      tittle: data['worktittle'] ?? '',
      description: data['description'] ?? '',
      maxbudget: data['maxbudget'],
      minbudget: data['minbudget'] as double,
      duration: data['duration'] ?? '',
      postedtime: (data['postedtime'] as Timestamp).toDate(),
      imagepath: data['imagepath'] ?? '',
    );
  }
}
