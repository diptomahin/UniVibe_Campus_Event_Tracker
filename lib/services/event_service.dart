import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/event_model.dart';
import 'notification_service.dart';

class EventService {
  final _supabase = Supabase.instance.client;

  Future<List<Event>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from(DatabaseTables.events)
          .select()
          .gt('start_time', now.toIso8601String())
          .eq('is_cancelled', false)
          .order('start_time', ascending: true)
          .limit(100);

      return (response as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<Event> getEventById(String eventId) async {
    try {
      final response = await _supabase
          .from(DatabaseTables.events)
          .select()
          .eq('id', eventId)
          .single();

      return Event.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching event: $e');
    }
  }

  Future<List<Event>> getEventsByCategory(String category) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from(DatabaseTables.events)
          .select()
          .eq('category', category)
          .gt('start_time', now.toIso8601String())
          .eq('is_cancelled', false)
          .order('start_time', ascending: true);

      return (response as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching events by category: $e');
    }
  }

  Future<List<Event>> getFeaturedEvents() async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from(DatabaseTables.events)
          .select()
          .eq('is_featured', true)
          .gt('start_time', now.toIso8601String())
          .eq('is_cancelled', false)
          .order('start_time', ascending: true)
          .limit(10);

      return (response as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching featured events: $e');
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from(DatabaseTables.events)
          .select()
          .gt('start_time', now.toIso8601String())
          .eq('is_cancelled', false)
          .or(
            'title.ilike.%$query%,description.ilike.%$query%,host_name.ilike.%$query%',
          )
          .order('start_time', ascending: true);

      return (response as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error searching events: $e');
    }
  }

  Future<void> createEvent(Event event) async {
    try {
      final eventData = event.toJson();

      await _supabase.from(DatabaseTables.events).insert(eventData);

      // Notify all users about the new event
      await _notifyAllUsersOfNewEvent(event);
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  // Helper method to notify all users about new event and schedule reminders
  Future<void> _notifyAllUsersOfNewEvent(Event event) async {
    try {
      print(
        '🔔 [DEBUG] Starting notification broadcast for event: ${event.id}',
      );
      final notificationService = NotificationService();

      // Get all users
      print('👥 [DEBUG] Fetching all users from database...');
      final allUsers = List<Map<String, dynamic>>.from(
        await _supabase.from(DatabaseTables.users).select('id') as List,
      );
      print('👥 [DEBUG] Found ${allUsers.length} users');

      for (var userDoc in allUsers) {
        final userId = userDoc['id'] as String;
        print('📝 [DEBUG] Creating notification for user: $userId');

        try {
          // Notify user about new event (no automatic reminder yet - only when they RSVP)
          await notificationService.notifyEventCreated(
            userId,
            event.id,
            event.title,
            event.hostName,
          );
          print('✅ [DEBUG] New event notification created for user: $userId');
        } catch (userError) {
          print(
            '❌ [DEBUG] Error creating notifications for user $userId: $userError',
          );
        }
      }

      print('✅ [DEBUG] Notifications created for all users');
    } catch (e) {
      print('⚠️ [DEBUG] Error notifying users: $e');
      print('⚠️ [DEBUG] Stack trace: ${StackTrace.current}');
      // Don't throw - event creation should succeed even if notifications fail
    }
  }

  Future<void> updateEvent(String eventId, Event event) async {
    try {
      await _supabase
          .from(DatabaseTables.events)
          .update(event.toJson())
          .eq('id', eventId);
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase.from(DatabaseTables.events).delete().eq('id', eventId);
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  Future<void> updateEventImageUrl(String eventId, String imageUrl) async {
    try {
      await _supabase
          .from(DatabaseTables.events)
          .update({'image_url': imageUrl})
          .eq('id', eventId);
    } catch (e) {
      throw Exception('Error updating event image: $e');
    }
  }

  Future<List<String>> getEventCategories() async {
    try {
      final response = await _supabase
          .from(DatabaseTables.categories)
          .select('name')
          .order('name', ascending: true);

      return (response as List).map((e) => e['name'] as String).toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
