class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String summary;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
