import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/event_model.dart';
import '../models/rsvp_notification_model.dart';
import 'notification_service.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<List<Event>> getGoingEvents(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.rsvps)
          .select('event_id')
          .eq('user_id', userId)
          .eq('status', 'going');

      final eventIds = (response as List)
          .map((e) => e['event_id'] as String)
          .toList();

      if (eventIds.isEmpty) return [];

      // Fetch events by joining with event IDs
      final allEvents = await _supabase
          .from(DatabaseTables.events)
          .select()
          .gt('start_time', DateTime.now().toIso8601String());

      final filteredEvents = (allEvents as List)
          .where((e) => eventIds.contains(e['id']))
          .toList();

      return filteredEvents
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching going events: $e');
    }
  }

  Future<List<Event>> getInterestedEvents(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.rsvps)
          .select('event_id')
          .eq('user_id', userId)
          .eq('status', 'interested');

      final eventIds = (response as List)
          .map((e) => e['event_id'] as String)
          .toList();

      if (eventIds.isEmpty) return [];

      // Fetch events by joining with event IDs
      final allEvents = await _supabase
          .from(DatabaseTables.events)
          .select()
          .gt('start_time', DateTime.now().toIso8601String());

      final filteredEvents = (allEvents as List)
          .where((e) => eventIds.contains(e['id']))
          .toList();

      return filteredEvents
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching interested events: $e');
    }
  }

  Future<List<Event>> getCreatedEvents(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.events)
          .select()
          .eq('host_id', userId)
          .order('start_time', ascending: false);

      return (response as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching created events: $e');
    }
  }

  Future<List<Event>> getPastEvents(String userId) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from(DatabaseTables.rsvps)
          .select('event_id')
          .eq('user_id', userId);

      final eventIds = (response as List)
          .map((e) => e['event_id'] as String)
          .toList();

      if (eventIds.isEmpty) return [];

      // Fetch events by joining with event IDs
      final allEvents = await _supabase
          .from(DatabaseTables.events)
          .select()
          .lt('end_time', now.toIso8601String())
          .order('start_time', ascending: false);

      final filteredEvents = (allEvents as List)
          .where((e) => eventIds.contains(e['id']))
          .toList();

      return filteredEvents
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching past events: $e');
    }
  }

  Future<List<Event>> getSavedEvents(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.users)
          .select('saved_event_ids')
          .eq('id', userId)
          .single();

      final savedEventIds = List<String>.from(
        response['saved_event_ids'] as List? ?? [],
      );

      if (savedEventIds.isEmpty) return [];

      // Fetch events by joining with saved event IDs
      final allEvents = await _supabase
          .from(DatabaseTables.events)
          .select()
          .order('start_time', ascending: true);

      final filteredEvents = (allEvents as List)
          .where((e) => savedEventIds.contains(e['id']))
          .toList();

      return filteredEvents
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching saved events: $e');
    }
  }

  Future<List<Notification>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<void> updateRsvpStatus(
    String userId,
    String eventId,
    String status,
  ) async {
    try {
      print(
        '📝 [UserService] Updating RSVP: user=$userId, event=$eventId, status=$status',
      );

      final existingRsvp = await _supabase
          .from(DatabaseTables.rsvps)
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();

      if (existingRsvp != null) {
        print('🔄 [UserService] Updating existing RSVP');
        await _supabase
            .from(DatabaseTables.rsvps)
            .update({
              'status': status,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('event_id', eventId);
        print('✅ [UserService] RSVP updated');
      } else {
        print('🆕 [UserService] Creating new RSVP');
        await _supabase.from(DatabaseTables.rsvps).insert({
          'user_id': userId,
          'event_id': eventId,
          'status': status,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ [UserService] RSVP created');
      }

      // Update event RSVP counts
      print('📊 [UserService] Calling _updateEventRsvpCounts...');
      await _updateEventRsvpCounts(eventId);

      // Schedule reminder if user marked as interested or going
      if (status == 'interested' || status == 'going') {
        await _scheduleReminderForRsvp(userId, eventId);
      }

      print('✅ [UserService] updateRsvpStatus completed');
    } catch (e) {
      print('❌ [UserService] Error updating RSVP status: $e');
      throw Exception('Error updating RSVP status: $e');
    }
  }

  // Helper method to schedule reminder when user RSVPs
  Future<void> _scheduleReminderForRsvp(String userId, String eventId) async {
    try {
      // Get event details
      final event = await getEventById(eventId);
      final notificationService = NotificationService();

      // Schedule reminder 1 day before event
      await notificationService.scheduleEventReminder(
        userId,
        eventId,
        event.title,
        event.startTime,
      );
    } catch (e) {
      // Don't throw - RSVP should succeed even if reminder scheduling fails
    }
  }

  Future<Event> getEventById(String eventId) async {
    final response = await _supabase
        .from(DatabaseTables.events)
        .select()
        .eq('id', eventId)
        .single();

    return Event.fromJson(response as Map<String, dynamic>);
  }

  Future<void> toggleSaveEvent(String userId, String eventId) async {
    try {
      final user = await _supabase
          .from(DatabaseTables.users)
          .select('saved_event_ids')
          .eq('id', userId)
          .single();

      List<String> savedEventIds = List<String>.from(
        user['saved_event_ids'] as List? ?? [],
      );

      if (savedEventIds.contains(eventId)) {
        savedEventIds.remove(eventId);
      } else {
        savedEventIds.add(eventId);
      }

      await _supabase
          .from(DatabaseTables.users)
          .update({'saved_event_ids': savedEventIds})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error toggling save event: $e');
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

  Future<void> _updateEventRsvpCounts(String eventId) async {
    try {
      print('🔄 [UserService] Updating RSVP counts for event: $eventId');

      final goingCountResponse = await _supabase
          .from(DatabaseTables.rsvps)
          .select()
          .eq('event_id', eventId)
          .eq('status', 'going');

      final interestedCountResponse = await _supabase
          .from(DatabaseTables.rsvps)
          .select()
          .eq('event_id', eventId)
          .eq('status', 'interested');

      final goingCount = (goingCountResponse as List).length;
      final interestedCount = (interestedCountResponse as List).length;

      print(
        '📊 [UserService] Going: $goingCount, Interested: $interestedCount',
      );

      final updateResponse = await _supabase
          .from(DatabaseTables.events)
          .update({
            'going_count': goingCount,
            'interested_count': interestedCount,
          })
          .eq('id', eventId);

      print('✅ [UserService] RSVP counts updated successfully');
      print('📝 [UserService] Update response: $updateResponse');
    } catch (e) {
      print('❌ [UserService] Error updating RSVP counts: $e');
      print('❌ [UserService] Stack trace: ${StackTrace.current}');
    }
  }

  // ==================== USER MANAGEMENT FEATURES ====================

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('👥 [UserService] Fetching all users');
      final response = await _supabase.from(DatabaseTables.users).select();
      print('✅ [UserService] Fetched ${(response as List).length} users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [UserService] Error fetching users: $e');
      throw Exception('Error fetching users: $e');
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.users)
          .select()
          .eq('id', userId)
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // Update user role (admin/student)
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      print('🔄 [UserService] Updating user role: $userId → $newRole');
      await _supabase
          .from(DatabaseTables.users)
          .update({'user_role': newRole})
          .eq('id', userId);
      print('✅ [UserService] User role updated successfully');
    } catch (e) {
      print('❌ [UserService] Error updating user role: $e');
      throw Exception('Error updating user role: $e');
    }
  }

  // Search users by email or name
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      print('🔍 [UserService] Searching users: $query');
      final response = await _supabase
          .from(DatabaseTables.users)
          .select()
          .or('email.ilike.%$query%,full_name.ilike.%$query%');
      print(
        '✅ [UserService] Found ${(response as List).length} matching users',
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ [UserService] Error searching users: $e');
      throw Exception('Error searching users: $e');
    }
  }

  // Get user event statistics
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // Count going events
      final goingResponse = await _supabase
          .from(DatabaseTables.rsvps)
          .select()
          .eq('user_id', userId)
          .eq('status', 'going');

      // Count interested events
      final interestedResponse = await _supabase
          .from(DatabaseTables.rsvps)
          .select()
          .eq('user_id', userId)
          .eq('status', 'interested');

      // Count created events
      final createdResponse = await _supabase
          .from(DatabaseTables.events)
          .select()
          .eq('host_id', userId);

      return {
        'going': (goingResponse as List).length,
        'interested': (interestedResponse as List).length,
        'created': (createdResponse as List).length,
      };
    } catch (e) {
      print('❌ [UserService] Error fetching user stats: $e');
      throw Exception('Error fetching user stats: $e');
    }
  }

  // Count users by role
  Future<Map<String, int>> countUsersByRole() async {
    try {
      final response = await _supabase.from(DatabaseTables.users).select();
      final users = (response as List).cast<Map<String, dynamic>>();

      int adminCount = 0;
      int studentCount = 0;

      for (var user in users) {
        if (user['user_role'] == 'admin') {
          adminCount++;
        } else {
          studentCount++;
        }
      }

      return {
        'admin': adminCount,
        'student': studentCount,
        'total': users.length,
      };
    } catch (e) {
      throw Exception('Error counting users: $e');
    }
  }

  // UC7: Update User Profile
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String bio,
  }) async {
    try {
      await _supabase
          .from(DatabaseTables.users)
          .update({
            'full_name': fullName,
            'email': email,
            'bio': bio,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }
}
