class Bookingmodel {
  final String bookingId;
  final String userId;
  final String providerId;
  final String description;
  final String bookingTime;
  final String bookingDate;
  String status;
  final String name;
  final String imagePath;
  final String phoneNumber;

  Bookingmodel(
    this.userId,
    this.providerId,
    this.description,
    this.bookingTime,
    this.bookingDate,
    this.status,
    this.name,
    this.imagePath,
    this.phoneNumber, {
    required this.bookingId,
  });

  factory Bookingmodel.fromMap({
    required Map<String, dynamic> data,
    required String bookingId,
    required String name,
    required String imagePath,
    String? phoneNumber,
  }) {
    return Bookingmodel(
      data['userId'] ?? '',
      data['providerId'] ?? '',
      data['description'] ?? '',
      data['bookingTime'] ?? '',
      data['bookingDate'] ?? '',
      data['status'] ?? 'pending',
      name,
      imagePath,
      phoneNumber ?? "",
      bookingId: bookingId,
    );
  }
}
