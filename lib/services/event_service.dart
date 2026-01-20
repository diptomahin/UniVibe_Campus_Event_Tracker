import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/event_model.dart';

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

      return Event.fromJson(response as Map<String, dynamic>);
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
      print('🚀 [DEBUG] Creating event with data: $eventData');
      print('🚀 [DEBUG] User ID: ${event.hostId}');

      final response = await _supabase
          .from(DatabaseTables.events)
          .insert(eventData);

      print('✅ [DEBUG] Event created successfully: ${event.id}');
      print('✅ [DEBUG] Response: $response');
    } catch (e) {
      print('❌ [DEBUG] Error creating event: $e');
      print('❌ [DEBUG] Full error details: ${e.runtimeType}');
      throw Exception('Error creating event: $e');
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
