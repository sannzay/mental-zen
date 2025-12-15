class MoodEntry {
  final String id;
  final String userId;
  final int moodScore;
  final String? note;
  final List<String> tags;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodScore,
    required this.createdAt,
    this.note,
    List<String>? tags,
  }) : tags = tags ?? const [];

  MoodEntry copyWith({
    String? id,
    String? userId,
    int? moodScore,
    String? note,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodScore: moodScore ?? this.moodScore,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MoodEntry.fromJson(String id, Map<String, dynamic> json) {
    return MoodEntry(
      id: id,
      userId: json['userId'] as String? ?? '',
      moodScore: json['moodScore'] as int? ?? 0,
      note: json['note'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: (json['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'moodScore': moodScore,
      'note': note,
      'tags': tags,
      'createdAt': createdAt,
    };
  }
}


