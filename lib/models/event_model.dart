import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? imageUrl;
  final String hostId;
  final String hostName;
  final int capacity;
  final String visibility; // 'Public', 'Private', 'University'
  final int interestedCount;
  final int goingCount;
  final bool isFeatured;
  final bool isCancelled;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.imageUrl,
    required this.hostId,
    required this.hostName,
    required this.capacity,
    this.visibility = 'Public',
    this.interestedCount = 0,
    this.goingCount = 0,
    this.isFeatured = false,
    this.isCancelled = false,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location'] as String,
      imageUrl: json['image_url'] as String?,
      hostId: json['host_id'] as String,
      hostName: json['host_name'] as String,
      capacity: json['capacity'] as int? ?? 0,
      visibility: json['visibility'] as String? ?? 'Public',
      interestedCount: json['interested_count'] as int? ?? 0,
      goingCount: json['going_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      cancelReason: json['cancel_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'host_id': hostId,
      'host_name': hostName,
      'capacity': capacity,
      'visibility': visibility,
      'interested_count': interestedCount,
      'going_count': goingCount,
      'is_featured': isFeatured,
      'is_cancelled': isCancelled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    // Only include cancel_reason if it's not null
    if (cancelReason != null) {
      json['cancel_reason'] = cancelReason;
    }
    return json;
  }

  String get formattedStartTime {
    return DateFormat('MMM d, yyyy h:mm a').format(startTime);
  }

  String get formattedStartDate {
    return DateFormat('MMM d, yyyy').format(startTime);
  }

  String get formattedStartTime24 {
    return DateFormat('HH:mm').format(startTime);
  }

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startTime.year == tomorrow.year &&
        startTime.month == tomorrow.month &&
        startTime.day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return startTime.isAfter(now) && startTime.isBefore(weekFromNow);
  }

  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  bool get isUpcoming {
    return startTime.isAfter(DateTime.now());
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? imageUrl,
    String? hostId,
    String? hostName,
    int? capacity,
    String? visibility,
    int? interestedCount,
    int? goingCount,
    bool? isFeatured,
    bool? isCancelled,
    String? cancelReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      capacity: capacity ?? this.capacity,
      visibility: visibility ?? this.visibility,
      interestedCount: interestedCount ?? this.interestedCount,
      goingCount: goingCount ?? this.goingCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
