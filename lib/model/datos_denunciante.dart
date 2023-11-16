class DenuncianteData {
  String? userId;
  String fullName;
  int ci;
  int phone;
  double lat;
  double long;
  String documentId;

  DenuncianteData({
    this.userId,
    required this.fullName,
    required this.ci,
    required this.phone,
    required this.lat,
    required this.long,
    required this.documentId,
  });
}
