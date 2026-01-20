class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String userRole; // 'student', 'staff', 'admin'
  final bool notificationsEnabled;
  final String preferredReminderTime; // '1h', '24h', 'custom'
  final String timezone;
  final bool darkModeEnabled;
  final List<String> savedEventIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.userRole = 'student',
    this.notificationsEnabled = true,
    this.preferredReminderTime = '24h',
    this.timezone = 'UTC',
    this.darkModeEnabled = false,
    this.savedEventIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      userRole: json['user_role'] as String? ?? 'student',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      preferredReminderTime:
          json['preferred_reminder_time'] as String? ?? '24h',
      timezone: json['timezone'] as String? ?? 'UTC',
      darkModeEnabled: json['dark_mode_enabled'] as bool? ?? false,
      savedEventIds: List<String>.from(json['saved_event_ids'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'user_role': userRole,
      'notifications_enabled': notificationsEnabled,
      'preferred_reminder_time': preferredReminderTime,
      'timezone': timezone,
      'dark_mode_enabled': darkModeEnabled,
      'saved_event_ids': savedEventIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isAdmin => userRole == 'admin';

  bool get isStaff => userRole == 'staff' || userRole == 'admin';

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? userRole,
    bool? notificationsEnabled,
    String? preferredReminderTime,
    String? timezone,
    bool? darkModeEnabled,
    List<String>? savedEventIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      userRole: userRole ?? this.userRole,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredReminderTime:
          preferredReminderTime ?? this.preferredReminderTime,
      timezone: timezone ?? this.timezone,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      savedEventIds: savedEventIds ?? this.savedEventIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
