class DenuncianteData{
  String? userId;
  String fullName;
  int ci;
  int phone;
  double lat;
  double long;

  DenuncianteData({
    this.userId,
    required this.fullName,
    required this.ci,
    required this.phone,
    required this.lat,
    required this.long,
  });
}