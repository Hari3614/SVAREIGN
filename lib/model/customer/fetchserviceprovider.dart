class Fetchserviceprovidermodel {
  String name;
  String imagepath;
  List<dynamic> role;
  String description;
  String hourlypayment;
  String serviceId;

  Fetchserviceprovidermodel({
    required this.name,
    required this.imagepath,
    required this.role,
    required this.description,
    required this.hourlypayment,
    required this.serviceId,
  });
  factory Fetchserviceprovidermodel.fromMap(Map<String, dynamic> data) {
    return Fetchserviceprovidermodel(
      name: data['fullname'] ?? 'unknown',
      imagepath: data['imageurl'] ?? 'unknown',
      role: data['categories'] ?? "",
      description: data['description'] ?? "",
      hourlypayment: data['payment'] ?? "",
      serviceId: data['serviceId'] ?? "",
    );
  }
  Map<String, dynamic> tomap() {
    return {
      "fullname": name,
      "imageurl": imagepath,
      "categories": role,
      "description": description,
      "payment": hourlypayment,
      "serviceId": serviceId,
    };
  }
}
