class IncidentData {
  String description;
  DateTime date;
  double lat;
  double long;
  String imageUrl = '';
  String audioUrl = '';

  IncidentData({
    required this.description,
    required this.date,
    required this.lat,
    required this.long,
    required this.imageUrl,
    required this.audioUrl,
  });
}