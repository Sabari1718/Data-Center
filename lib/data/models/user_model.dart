class UserModel {
  final String id;
  final String? userMainId;
  final String? username;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final String company;
  final String department;
  final bool twoFactorEnabled;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    this.userMainId,
    this.username,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = 'Infrastructure Admin',
    this.company = 'DataCenter Global Corp',
    this.department = 'Cloud Operations',
    this.twoFactorEnabled = true,
    this.createdAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['user_main_id'] ?? '';
    final rawName = json['name'] as String? ?? json['username'] as String? ?? '';
    return UserModel(
      id: rawId.toString(),
      userMainId: json['user_main_id']?.toString(),
      username: json['username'] as String?,
      name: rawName.isNotEmpty ? rawName : 'User',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'Infrastructure Admin',
      company: json['company'] as String? ?? 'DataCenter Global Corp',
      department: json['department'] as String? ?? 'Cloud Operations',
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_main_id': userMainId,
      'username': username,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role,
      'company': company,
      'department': department,
      'twoFactorEnabled': twoFactorEnabled,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? userMainId,
    String? username,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    String? company,
    String? department,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      userMainId: userMainId ?? this.userMainId,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      company: company ?? this.company,
      department: department ?? this.department,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
