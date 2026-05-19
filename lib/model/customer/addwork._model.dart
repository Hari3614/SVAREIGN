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
  final DateTime expirytime;
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
    DateTime? expirytime,
  }) : expirytime = expirytime ?? postedtime.add(const Duration(hours: 24));

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
      expirytime: map['expirytime'] != null
          ? (map['expirytime'] as Timestamp).toDate()
          : null,
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
      'expirytime': expirytime,
      "imagepath": imagepath,
    };
  }
}
