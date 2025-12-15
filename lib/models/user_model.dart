class UserModel {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> settings;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      createdAt: (json['createdAt'] as DateTime?) ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as DateTime?) ?? DateTime.now(),
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'settings': settings,
    };
  }
}


