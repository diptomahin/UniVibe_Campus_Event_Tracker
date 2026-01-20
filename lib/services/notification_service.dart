import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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

      final notifications = (response as List)
          .map((n) => Notification.fromJson(n as Map<String, dynamic>))
          .toList();

      return notifications;
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
  Future<void> notifyEventCreated(
    String userId,
    String eventId,
    String eventTitle,
    String hostName,
  ) async {
    final notification = Notification(
      id: const Uuid().v4(),
      userId: userId,
      eventId: eventId,
      title: 'New Event Created',
      message: '$hostName created a new event: $eventTitle',
      type: 'new_event',
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  Future<void> scheduleEventReminder(
    String userId,
    String eventId,
    String eventTitle,
    DateTime eventStartTime,
  ) async {
    // Calculate reminder time: 1 day before event
    final reminderTime = eventStartTime.subtract(Duration(days: 1));

    final notification = Notification(
      id: const Uuid().v4(),
      userId: userId,
      eventId: eventId,
      title: 'Event Reminder',
      message: '$eventTitle is happening tomorrow!',
      type: 'reminder',
      createdAt: DateTime.now(),
      scheduledFor: reminderTime,
    );
    await createNotification(notification);
  }

  Future<void> notifyEventReminder(
    String userId,
    String eventId,
    String eventTitle,
  ) async {
    final notification = Notification(
      id: const Uuid().v4(),
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
      id: const Uuid().v4(),
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
      id: const Uuid().v4(),
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
      id: const Uuid().v4(),
      userId: userId,
      eventId: eventId,
      title: 'Featured Event',
      message: '$eventTitle is now featured!',
      type: 'announcement',
      createdAt: DateTime.now(),
    );
    await createNotification(notification);
  }

  // Get scheduled reminders that are due
  Future<List<Notification>> getDueReminders() async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from(DatabaseTables.notifications)
          .select()
          .eq('type', 'reminder')
          .eq('is_read', false)
          .lte('scheduled_for', now.toIso8601String())
          .not('scheduled_for', 'is', null)
          .order('scheduled_for', ascending: true);

      return (response as List)
          .map((n) => Notification.fromJson(n as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching due reminders: $e');
    }
  }
}
