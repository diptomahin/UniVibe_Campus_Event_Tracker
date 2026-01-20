import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/rsvp_notification_model.dart';

class NotificationService {
  final _supabase = Supabase.instance.client;

  Future<List<Notification>> getUserNotifications(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((n) => Notification.fromJson(n as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<void> createNotification(Notification notification) async {
    try {
      await _supabase
          .from(DatabaseTables.notifications)
          .insert(notification.toJson());
    } catch (e) {
      throw Exception('Error creating notification: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase
          .from(DatabaseTables.notifications)
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _supabase
          .from(DatabaseTables.notifications)
          .update({'is_read': true})
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Error marking notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from(DatabaseTables.notifications)
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  // Helper methods for common notifications
  Future<void> notifyEventReminder(
    String userId,
    String eventId,
    String eventTitle,
  ) async {
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventId: eventId,
      title: 'Event Reminder',
      message: '$eventTitle is starting soon!',
      type: 'reminder',
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  Future<void> notifyEventCancelled(
    String userId,
    String eventId,
    String eventTitle,
  ) async {
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventId: eventId,
      title: 'Event Cancelled',
      message: '$eventTitle has been cancelled.',
      type: 'announcement',
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  Future<void> notifyEventAnnouncement(
    String userId,
    String eventId,
    String eventTitle,
    String announcement,
  ) async {
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventId: eventId,
      title: 'Announcement: $eventTitle',
      message: announcement,
      type: 'announcement',
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  Future<void> notifyEventFeatured(
    String userId,
    String eventId,
    String eventTitle,
  ) async {
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      eventId: eventId,
      title: 'Featured Event',
      message: '$eventTitle is now featured!',
      type: 'announcement',
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }
}
