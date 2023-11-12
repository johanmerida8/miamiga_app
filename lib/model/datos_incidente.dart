class IncidentData {
  String description;
  DateTime date;
  double lat;
  double long;
  List<String> imageUrls = [];
  String audioUrl = '';

  IncidentData({
    required this.description,
    required this.date,
    required this.lat,
    required this.long,
    required this.imageUrls,
    required this.audioUrl,
  });
}