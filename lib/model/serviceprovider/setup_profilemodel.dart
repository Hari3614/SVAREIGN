class Profile {
  final String fullname;
  final String description;
  final List<String> categories;
  final String experience;
  final String payment;
  final String? imageurl;
  Profile({
    required this.fullname,
    required this.description,
    required this.experience,
    required this.categories,
    required this.imageurl,
    required this.payment,
  });
  Map<String, dynamic> tomap() {
    return {
      'fullname': fullname,
      'description': description,
      'categories': categories,
      'experience': experience,
      'payment': payment,
      'imageurl': imageurl,
    };
  }

  factory Profile.frommap(Map<String, dynamic> map) {
    return Profile(
      fullname: map['fullname'],
      description: map['description'],
      experience: map['experience'],
      categories: ['categories'],
      imageurl: map['imageurl'],
      payment: map['payment'],
    );
  }
}
