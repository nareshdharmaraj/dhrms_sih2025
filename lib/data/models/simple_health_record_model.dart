class SimpleHealthRecord {
  final String id;
  final String userId;
  final String recordType;
  final String title;
  final DateTime date;
  final String description;
  final List<String> attachments;
  final String createdBy;
  final List<String> tags;

  const SimpleHealthRecord({
    required this.id,
    required this.userId,
    required this.recordType,
    required this.title,
    required this.date,
    required this.description,
    this.attachments = const [],
    required this.createdBy,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recordType': recordType,
      'title': title,
      'date': date.toIso8601String(),
      'description': description,
      'attachments': attachments,
      'createdBy': createdBy,
      'tags': tags,
    };
  }

  factory SimpleHealthRecord.fromJson(Map<String, dynamic> json) {
    return SimpleHealthRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      recordType: json['recordType'] ?? '',
      title: json['title'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      createdBy: json['createdBy'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
