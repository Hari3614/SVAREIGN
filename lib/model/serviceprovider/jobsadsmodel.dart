import 'package:cloud_firestore/cloud_firestore.dart';

class Jobsadsmodel {
  final String id;
  final String providerid;
  final String tittle;
  final String description;
  final double budget;
  final List<String> imageurl;
  final String starttime;
  final String endtime;
  final DateTime postedtime;
  final DateTime expirytime;
  final String phonenumber;
  Jobsadsmodel({
    this.id = '',
    required this.providerid,
    required this.tittle,
    required this.description,
    required this.budget,
    required this.imageurl,
    required this.starttime,
    required this.endtime,
    required this.postedtime,
    required this.expirytime,
    this.phonenumber = '',
  });
  factory Jobsadsmodel.fromMap(String documentId, Map<String, dynamic> map) {
    return Jobsadsmodel(
      id: documentId,
      providerid: map['providerId'] ?? "",
      tittle: map['tittle'] ?? "",
      description: map['description'] ?? "",
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      imageurl: List<String>.from(map['imageurl'] ?? []),
      starttime: map['starttime'] ?? '',
      endtime: map['endtime'] ?? '',
      postedtime:
          map['postedtime'] != null
              ? (map['postedtime'] as Timestamp).toDate()
              : DateTime.now(),
      expirytime:
          map['expirytime'] != null
              ? (map['expirytime'] as Timestamp).toDate()
              : DateTime.now().add(const Duration(hours: 24)),
      phonenumber: map['phonenumber'] ?? '',
    );
  }

  Map<String, dynamic> tomap() {
    return {
      'providerId': providerid, // Use providerId (uppercase I) for consistency
      'tittle': tittle,
      "description": description,
      "budget": budget,
      'imageurl': imageurl,
      'starttime': starttime,
      'endtime': endtime,
      "postedtime": postedtime,
      "expirytime": expirytime,
    };
  }
}
