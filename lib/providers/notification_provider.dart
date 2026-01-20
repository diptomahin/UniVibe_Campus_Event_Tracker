import 'package:flutter/material.dart';
import 'dart:async';
import '../models/rsvp_notification_model.dart' as notification_model;
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<notification_model.Notification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _reminderCheckTimer;

  List<notification_model.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider();

  Future<void> loadNotifications(String userId) async {
    _setLoading(true);
    try {
      _notifications = await _notificationService.getUserNotifications(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Start periodic check for due reminders
  void startReminderCheck(String userId) {
    // Check every minute for due reminders
    _reminderCheckTimer = Timer.periodic(Duration(minutes: 1), (_) async {
      await _checkAndDisplayDueReminders(userId);
    });
  }

  /// Stop the reminder check
  void stopReminderCheck() {
    _reminderCheckTimer?.cancel();
    _reminderCheckTimer = null;
  }

  /// Check for reminders that are due and add them to notifications
  Future<void> _checkAndDisplayDueReminders(String userId) async {
    try {
      final dueReminders = await _notificationService.getDueReminders();

      if (dueReminders.isNotEmpty) {
        // Add due reminders to the notifications list
        for (var reminder in dueReminders) {
          if (reminder.userId == userId &&
              !_notifications.any((n) => n.id == reminder.id)) {
            _notifications.insert(0, reminder);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      // Error checking due reminders
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Update is complex, so reload
        await loadNotifications(_notifications[0].userId);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllNotificationsAsRead(userId);
      // Reload all notifications
      await loadNotifications(userId);
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // UC8: Broadcast Announcement
  Future<void> broadcastAnnouncement({
    required String title,
    required String message,
  }) async {
    _setLoading(true);
    try {
      await _notificationService.broadcastAnnouncement(
        title: title,
        message: message,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    stopReminderCheck();
    super.dispose();
  }
}
