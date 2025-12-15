class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final int? moodScore;
  final List<String> tags;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.moodScore,
    List<String>? tags,
    this.isFavorite = false,
  }) : tags = tags ?? const [];

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    int? moodScore,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      moodScore: moodScore ?? this.moodScore,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory JournalEntry.fromJson(String id, Map<String, dynamic> json) {
    return JournalEntry(
      id: id,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      moodScore: json['moodScore'] as int?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: (json['createdAt'] as DateTime?) ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'moodScore': moodScore,
      'tags': tags,
      'isFavorite': isFavorite,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}


