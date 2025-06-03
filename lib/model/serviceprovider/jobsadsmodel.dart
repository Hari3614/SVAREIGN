import 'package:cloud_firestore/cloud_firestore.dart';

class Jobsadsmodel {
  final String providerid;
  final String tittle;
  final String description;
  final double budget;
  final List<String> imageurl;
  final String starttime;
  final String endtime;
  final DateTime postedtime;
  Jobsadsmodel({
    required this.providerid,
    required this.tittle,
    required this.description,
    required this.budget,
    required this.imageurl,
    required this.starttime,
    required this.endtime,
    required this.postedtime,
  });
  factory Jobsadsmodel.fromMap(Map<String, dynamic> map) {
    return Jobsadsmodel(
      providerid: map['providerId'] ?? "",
      tittle: map['tittle'] ?? "",
      description: map['description'] ?? "",
      budget: map['budget'] as double,
      imageurl: List<String>.from(map['imageurl']),
      starttime: map['starttime'],
      endtime: map['endtime'],
      postedtime: (map['postedtime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> tomap() {
    return {
      'providerId': providerid,
      'tittle': tittle,
      "description": description,
      "budget": budget,
      'imageurl': imageurl,
      'starttime': starttime,
      'endtime': endtime,
      "postedtime": postedtime,
    };
  }
}
