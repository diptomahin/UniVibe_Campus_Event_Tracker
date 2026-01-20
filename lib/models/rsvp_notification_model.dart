class RSVP {
  final String id;
  final String userId;
  final String eventId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RSVP({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RSVP.fromJson(Map<String, dynamic> json) {
    return RSVP(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Notification {
  final String id;
  final String userId;
  final String eventId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? scheduledFor;

  Notification({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.scheduledFor,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
    if (scheduledFor != null) {
      json['scheduled_for'] = scheduledFor!.toIso8601String();
    }
    return json;
  }
}
