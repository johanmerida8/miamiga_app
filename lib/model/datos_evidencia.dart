class EvidenceData {
  String description;
  DateTime date;
  double lat;
  double long;
  List<String> imageUrls = [];
  String audioUrl = '';
  String documentUrl = '';

  EvidenceData({
    required this.description,
    required this.date,
    required this.lat,
    required this.long,
    required this.imageUrls,
    required this.audioUrl,
    required this.documentUrl,
  });
}