class Reqstmodel {
  final String jobId;
  final String providerid;
  final String? name;
  final String? imagepath;
  final String? hourlypayment;
  final String? experience;
  final List<String>? jobs;

  Reqstmodel({
    required this.providerid,
    required this.jobId,
    this.experience,
    this.hourlypayment,
    this.imagepath,
    this.jobs,
    this.name,
  });

  factory Reqstmodel.fromMap(Map<String, dynamic> map) {
    return Reqstmodel(
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
    };
  }
}
