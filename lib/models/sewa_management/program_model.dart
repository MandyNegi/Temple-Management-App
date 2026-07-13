class SewaProgramModel {
  String? id;
  String title;
  String leader;
  String manager;
  String location;
  DateTime scheduledAt;

  SewaProgramModel({this.id, required this.title, required this.leader, required this.manager, required this.location, required this.scheduledAt});

  factory SewaProgramModel.fromJson(Map<String, dynamic> json, String id) {
    return SewaProgramModel(
      id: id,
      title: json['title'] ?? '',
      leader: json['leader'] ?? '',
      manager: json['manager'] ?? '',
      location: json['location'] ?? '',
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'leader': leader,
      'manager': manager,
      'location': location,
      'scheduledAt': scheduledAt.toIso8601String(),
    };
  }
}
