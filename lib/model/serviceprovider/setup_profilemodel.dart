class Profile {
  final String id;
  final String fullname;
  final String description;
  final List<String> categories;
  final String experience;
  final String payment;
  final String? imageurl;
  final String upiId;
  Profile({
    required this.id,
    required this.fullname,
    required this.description,
    required this.experience,
    required this.categories,
    required this.imageurl,
    required this.payment,
    required this.upiId,
  });
  Map<String, dynamic> tomap() {
    return {
      'serviceId': id,
      'fullname': fullname,
      'description': description,
      'categories': categories,
      'experience': experience,
      'payment': payment,
      'imageurl': imageurl,
      'upiId': upiId,
    };
  }

  factory Profile.frommap(Map<String, dynamic> map) {
    return Profile(
      id: map['serviceId'],
      fullname: map['fullname'],
      description: map['description'],
      experience: map['experience'],
      categories: ['categories'],
      imageurl: map['imageurl'],
      payment: map['payment'],
      upiId: map['upiId'],
    );
  }
}
