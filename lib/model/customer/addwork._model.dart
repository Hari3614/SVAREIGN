import 'package:cloud_firestore/cloud_firestore.dart';

class Addworkmodel {
  final String worktittle;
  final double budget;
  final String description;
  final String duration;
  final DateTime postedtime;

  Addworkmodel({
    required this.worktittle,
    required this.budget,
    required this.description,
    required this.duration,
    required this.postedtime,
  });

  factory Addworkmodel.fromMap(Map<String, dynamic> map) {
    return Addworkmodel(
      worktittle: map['worktittle'] ?? '',
      budget: map['budget'] as double,
      description: map['description'] ?? '',
      duration: map['duration'] ?? '',
      postedtime: (map['postedtime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> tomap() {
    return {
      'worktittle': worktittle,
      'budget': budget,
      'description': description,
      'duration': duration,
      'postedtime': postedtime,
    };
  }
}
