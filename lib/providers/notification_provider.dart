import 'package:flutter/material.dart';
import '../models/rsvp_notification_model.dart' as notification_model;
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<notification_model.Notification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
