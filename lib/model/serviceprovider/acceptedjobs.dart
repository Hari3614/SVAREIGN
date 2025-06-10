class Acceptedjobs {
  final String userid;
  final String workId;
  final String requestId;
  final String customername;
  final String workname;
  final double budget;
  final String phonenumber;

  bool isaccepted;
  bool iscompleted;
  Acceptedjobs({
    required this.userid,
    required this.workId,
    required this.requestId,
    required this.customername,
    required this.phonenumber,
    required this.workname,
    required this.budget,
    this.isaccepted = false,
    this.iscompleted = false,
  });
}
