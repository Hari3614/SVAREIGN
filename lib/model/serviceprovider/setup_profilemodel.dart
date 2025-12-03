class Profile {
  final String? id;
  final String fullname;
  final String? description;
  final List<String>? categories;
  final String? experience;
  final String payment;
  final String? imageurl;
  final String upiId;
  final String? phone;
  
  Profile({
    this.id,
    required this.fullname,
    this.description,
    this.experience,
    this.categories,
    required this.imageurl,
    required this.payment,
    required this.upiId,
    this.phone,
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
      'phone': phone,
    };
  }

  factory Profile.frommap(Map<String, dynamic> map) {
    return Profile(
      id: map['serviceId'],
      fullname: map['fullname'],
      description: map['description'],
      experience: map['experience'],
      categories: map['categories'] is List ? List<String>.from(map['categories']) : [],
      imageurl: map['imageurl'],
      payment: map['payment'],
      upiId: map['upiId'],
      phone: map['phone'],
    );
  }
}