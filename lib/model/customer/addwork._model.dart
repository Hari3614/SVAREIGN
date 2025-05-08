class Addworkmodel {
  final String? imagepath;
  final String worktittle;
  final String description;
  final String duration;
  final double budget;
  final DateTime postedtime;

  Addworkmodel({
    required this.worktittle,
    required this.description,
    required this.duration,
    required this.budget,
    required this.postedtime,
    this.imagepath,
  });

  Map<String, dynamic> tomap() {
    return {
      'worktittle': worktittle,
      'description': description,
      'duration': duration,
      'postedtime': postedtime.toIso8601String(),
      'imagepath': imagepath,
      'budget': budget,
    };
  }

  factory Addworkmodel.fromMap(Map<String, dynamic> map) {
    return Addworkmodel(
      worktittle: map['worktittle'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? '',
      postedtime: DateTime.parse(map['postedtime']),
      imagepath: map['imagepath'],
      budget:
          (map['budget'] is int)
              ? (map['budget'] as int).toDouble()
              : map['budget'] ?? 0.0,
    );
  }
}
