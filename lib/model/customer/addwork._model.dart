import 'package:cloud_firestore/cloud_firestore.dart';

class Addworkmodel {
  final String id;
  final String worktittle;
  final double minbudget;
  final double maxbudget;
  final String description;
  final String duration;
  final DateTime postedtime;
  final String? imagepath;
  final String userId;
  final String status;
  Addworkmodel({
    required this.id,
    required this.worktittle,
    required this.minbudget,
    required this.description,
    required this.duration,
    required this.postedtime,
    this.imagepath,
    required this.userId,
    required this.maxbudget,
    required this.status,
  });

  factory Addworkmodel.fromMap(Map<String, dynamic> map, String documentId) {
    return Addworkmodel(
      id: documentId,
      status: map['status'] ?? "",
      userId: map['userId'] ?? "",
      worktittle: map['worktittle'] ?? '',
      minbudget: map['minbudget'] as double,
      maxbudget: map['maxbudget'] as double,
      description: map['description'] ?? '',
      duration: map['duration'] ?? '',
      postedtime: (map['postedtime'] as Timestamp).toDate(),
      imagepath: map['imagepath'] ?? "",
    );
  }

  Map<String, dynamic> tomap() {
    return {
      'status': status,
      'userId': userId,
      'worktittle': worktittle,
      'minbudget': minbudget,
      'maxbudget': maxbudget,
      'description': description,
      'duration': duration,
      'postedtime': postedtime,
      "imagepath": imagepath,
    };
  }
}
