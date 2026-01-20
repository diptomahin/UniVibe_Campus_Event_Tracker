import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/rsvp_notification_model.dart' as notification_model;
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<Event> _goingEvents = [];
  List<Event> _interestedEvents = [];
  List<Event> _createdEvents = [];
  List<Event> _pastEvents = [];
  List<Event> _savedEvents = [];
  List<notification_model.Notification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get goingEvents => _goingEvents;
  List<Event> get interestedEvents => _interestedEvents;
  List<Event> get createdEvents => _createdEvents;
  List<Event> get pastEvents => _pastEvents;
  List<Event> get savedEvents => _savedEvents;
  List<notification_model.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserEvents(String userId) async {
    _setLoading(true);
    try {
      _goingEvents = await _userService.getGoingEvents(userId);
      _interestedEvents = await _userService.getInterestedEvents(userId);
      _createdEvents = await _userService.getCreatedEvents(userId);
      _pastEvents = await _userService.getPastEvents(userId);
      _savedEvents = await _userService.getSavedEvents(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNotifications(String userId) async {
    try {
      _notifications = await _userService.getNotifications(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> updateRsvpStatus(
    String userId,
    String eventId,
    String status,
  ) async {
    try {
      await _userService.updateRsvpStatus(userId, eventId, status);
      await loadUserEvents(userId);
      // Notify listeners to update UI immediately with new RSVP status
      notifyListeners();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleSaveEvent(String userId, String eventId) async {
    try {
      await _userService.toggleSaveEvent(userId, eventId);
      await loadUserEvents(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _userService.markNotificationAsRead(notificationId);
      _notifications = _notifications.map((n) {
        if (n.id == notificationId) {
          return notification_model.Notification(
            id: n.id,
            userId: n.userId,
            eventId: n.eventId,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
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
