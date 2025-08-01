class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? imageurl;
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.imageurl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      imageurl: data['imageurl'] ?? "",
    );
  }

  // get imageUrl => null;
}
