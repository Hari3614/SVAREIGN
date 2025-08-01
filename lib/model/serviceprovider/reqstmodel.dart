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
    return Reqstmodel(
      upiId: map['upiId'],
      userId: map['userId'],
      phonenumber: map['phone'],
      id: documentId,
      finalamount: map['finalAmount'],
      status: map['status'],
      providerid: map['providerId'],
      jobId: map['jobId'],
      name: map['name'],
      imagepath: map['imagepath'],
      hourlypayment: map['hourlypayment'],
      experience: map['experience'],
      jobs: map['job'] != null ? List<String>.from(map['job']) : null, // ✅
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
      'job': jobs,
      'status': status,
      "phone": phonenumber,
      "userId": userId,
      "finalAmount": finalamount,
      'upiId': upiId,
    };
  }
}
