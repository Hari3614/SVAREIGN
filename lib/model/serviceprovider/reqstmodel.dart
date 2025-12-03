class Reqstmodel {
  final String id;
  final String jobId;
  final String providerid;
  final String? name;
  final String? imagepath;
  final String? hourlypayment;
  final String? experience;
  final List<String>? jobs;
  final String status;
  final String phonenumber;
  final String userId;
  final double finalamount;
  final String upiId;

  Reqstmodel({
    required this.id,
    required this.providerid,
    required this.jobId,
    required this.status,
    this.experience,
    this.hourlypayment,
    this.imagepath,
    this.jobs,
    this.name,
    required this.phonenumber,
    required this.userId,
    required this.finalamount,
    required this.upiId,
  });

  factory Reqstmodel.fromMap(String documentId, Map<String, dynamic> map) {
    // Debug print to see what data we're getting
    print("Creating Reqstmodel from map: $map");

    return Reqstmodel(
      upiId: map['upiId'] ?? '',
      userId: map['userId'] ?? '',
      phonenumber: map['phone'] ?? map['phonenumber'] ?? '',
      id: documentId,
      finalamount:
          map['finalAmount'] is num ? map['finalAmount'].toDouble() : 0.0,
      status: map['status'] ?? 'pending',
      providerid: map['providerId'] ?? '',
      jobId: map['jobId'] ?? '',
      name: map['name'] ?? map['fullname'] ?? '',
      imagepath: map['imagepath'] ?? map['imageurl'] ?? '',
      hourlypayment: map['hourlypayment'] ?? map['payment'] ?? '',
      experience: map['experience']?.toString() ?? '',
      jobs:
          map['job'] != null
              ? (map['job'] is List
                  ? List<String>.from(map['job'])
                  : [map['job'].toString()])
              : (map['jobs'] != null
                  ? (map['jobs'] is List
                      ? List<String>.from(map['jobs'])
                      : [map['jobs'].toString()])
                  : []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerid,
      'jobId': jobId,
      'name': name,
      'imagepath': imagepath,
      'hourlypayment': hourlypayment,
      'experience': experience,
      'jobs': jobs,
      'status': status,
      "phone": phonenumber,
      "userId": userId,
      "finalAmount": finalamount,
      'upiId': upiId,
    };
  }
}
