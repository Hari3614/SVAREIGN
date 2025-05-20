import 'package:cloud_firestore/cloud_firestore.dart';

class Addworkmodel {
  final String worktittle;
  final double budget;
  final String description;
  final String duration;
  final DateTime postedtime;
  final String? imagepath;
  final String userId;
  Addworkmodel({
    required this.worktittle,
    required this.budget,
    required this.description,
    required this.duration,
    required this.postedtime,
    this.imagepath,
    required this.userId,
  });

  factory Addworkmodel.fromMap(Map<String, dynamic> map) {
    return Addworkmodel(
      userId: map['userId'] ?? "",
      worktittle: map['worktittle'] ?? '',
      budget: map['budget'] as double,
      description: map['description'] ?? '',
      duration: map['duration'] ?? '',
      postedtime: (map['postedtime'] as Timestamp).toDate(),
      imagepath: map['imagepath'] ?? "",
    );
  }

  Map<String, dynamic> tomap() {
    return {
      'userId': userId,
      'worktittle': worktittle,
      'budget': budget,
      'description': description,
      'duration': duration,
      'postedtime': postedtime,
      "imagepath": imagepath,
    };
  }
}
