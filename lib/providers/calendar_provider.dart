import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/supabase_service.dart';

class CalendarProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  Map<DateTime, List<CalendarEvent>> _events = {};
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  Map<DateTime, List<CalendarEvent>> get events => _events;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CalendarEvent> getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFocusedDate(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  Future<void> loadEventsForMonth(int year, int month) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📅 Loading events for $year-$month...');
      _events = await _supabaseService.getEventsForMonth(year, month);
      print('✅ Loaded ${_events.values.fold(0, (sum, events) => sum + events.length)} events');

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading calendar events: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createEvent({
    required String eventName,
    String? eventDescription,
    required DateTime eventDate,
    String? eventTime,
  }) async {
    try {
      await _supabaseService.createEvent(
        eventName: eventName,
        eventDescription: eventDescription,
        eventDate: eventDate,
        eventTime: eventTime,
      );

      await loadEventsForMonth(eventDate.year, eventDate.month);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEvent(
    String eventId,
    DateTime eventDate, {
    String? eventName,
    String? eventDescription,
    DateTime? newEventDate,
    String? eventTime,
    bool? isCompleted,
  }) async {
    try {
      await _supabaseService.updateEvent(
        eventId,
        eventName: eventName,
        eventDescription: eventDescription,
        eventDate: newEventDate,
        eventTime: eventTime,
        isCompleted: isCompleted,
      );

      await loadEventsForMonth(eventDate.year, eventDate.month);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId, DateTime eventDate) async {
    try {
      await _supabaseService.deleteEvent(eventId);
      await loadEventsForMonth(eventDate.year, eventDate.month);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
