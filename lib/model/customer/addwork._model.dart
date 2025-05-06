class Addworkmodel {
  final String? imagepath;
  final String worktittle;
  final String description;
  final String providername;
  final String date;
  final int minbudget;
  final int maxbudget;
  Addworkmodel({
    required this.worktittle,
    required this.description,
    required this.date,
    required this.providername,
    this.imagepath,
    required this.maxbudget,
    required this.minbudget,
  });
  Map<String, dynamic> tomap() {
    return {
      'worktittle': worktittle,
      'decription': description,
      'providername': providername,
      'date': date,
      'imagepath': imagepath,
      'minbudget': minbudget,
      'maxbudget': maxbudget,
    };
  }

  factory Addworkmodel.fromMap(Map<String, dynamic> map) {
    return Addworkmodel(
      worktittle: map['worktittle'] as String,
      description: map['description'] as String,
      date: map['date'] as String,
      providername: map['providername'] as String,
      imagepath: map['imagepath'] as String?,
      minbudget: map['minbudget'] as int,
      maxbudget: map['maxbudget'] as int,
    );
  }
}
