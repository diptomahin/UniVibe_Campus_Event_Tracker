import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  Event? _selectedEvent;
  bool _isLoading = false;
  String? _errorMessage;

  // Filter state
  List<String> _selectedCategories = [];
  String _sortBy = 'soonest'; // 'soonest', 'popularity'
  DateTime? _startDate;
  DateTime? _endDate;

  List<Event> get allEvents => _allEvents;
  List<Event> get filteredEvents => _filteredEvents;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get selectedCategories => _selectedCategories;
  String get sortBy => _sortBy;

  EventProvider() {
    loadEvents();
  }

  Future<void> loadEvents() async {
    _setLoading(true);
    try {
      _allEvents = await _eventService.getUpcomingEvents();
      _applyFilters();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadEventDetails(String eventId) async {
    try {
      _selectedEvent = await _eventService.getEventById(eventId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  Future<void> createEvent(Event event) async {
    _setLoading(true);
    try {
      print('🔵 [EventProvider] Creating event: ${event.title}');
      await _eventService.createEvent(event);
      print('🟢 [EventProvider] Event created, reloading events...');
      await loadEvents();
      _errorMessage = null;
      print('🟢 [EventProvider] Events reloaded successfully');
    } catch (e) {
      _errorMessage = e.toString();
      print('🔴 [EventProvider] Error: $e');
      rethrow; // Re-throw so the screen can handle it
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEvent(String eventId, Event event) async {
    _setLoading(true);
    try {
      await _eventService.updateEvent(eventId, event);
      await loadEvents();
      if (_selectedEvent?.id == eventId) {
        _selectedEvent = event;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _setLoading(true);
    try {
      await _eventService.deleteEvent(eventId);
      await loadEvents();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void setCategoryFilter(List<String> categories) {
    _selectedCategories = categories;
    _applyFilters();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applyFilters();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredEvents = _allEvents.where((event) {
      // Category filter
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(event.category)) {
        return false;
      }

      // Date range filter
      if (_startDate != null && event.endTime.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && event.startTime.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    if (_sortBy == 'popularity') {
      _filteredEvents.sort(
        (a, b) => (b.goingCount + b.interestedCount).compareTo(
          a.goingCount + a.interestedCount,
        ),
      );
    } else {
      _filteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    notifyListeners();
  }

  Future<List<Event>> searchEvents(String query) async {
    _setLoading(true);
    try {
      final results = await _eventService.searchEvents(query);
      return results;
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
