class Reminder {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String time;
  final List<int> daysOfWeek;
  final bool isEnabled;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.time,
    required this.daysOfWeek,
    required this.createdAt,
    this.isEnabled = true,
  });

  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? time,
    List<int>? daysOfWeek,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Reminder.fromJson(String id, Map<String, dynamic> json) {
    return Reminder(
      id: id,
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      time: json['time'] as String? ?? '',
      daysOfWeek: (json['daysOfWeek'] as List?)?.map((e) => e as int).toList() ?? const [],
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: (json['createdAt'] as DateTime?) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'time': time,
      'daysOfWeek': daysOfWeek,
      'isEnabled': isEnabled,
      'createdAt': createdAt,
    };
  }
}


