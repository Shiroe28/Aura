import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/supabase_service.dart';

class JournalProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEntries() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📔 Loading journal entries...');
      _entries = await _supabaseService.getJournalEntries();
      print('✅ Loaded ${_entries.length} journal entries');

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading journal entries: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createEntry({
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.createJournalEntry(
        title: title,
        content: content,
        tags: tags,
      );

      await loadEntries();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEntry({
    required String entryId,
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    try {
      await _supabaseService.updateJournalEntry(
        entryId: entryId,
        title: title,
        content: content,
        tags: tags,
      );

      await loadEntries();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _supabaseService.deleteJournalEntry(entryId);
      await loadEntries();
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
