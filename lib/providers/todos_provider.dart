import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/daily_reflection.dart';
import '../services/supabase_service.dart';

class TodosProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Todo> _todos = [];
  DailyReflection? _todayReflection;
  bool _isLoading = false;
  String? _errorMessage;

  List<Todo> get todos => _todos;
  DailyReflection? get todayReflection => _todayReflection;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Todo> get completedTodos => 
      _todos.where((todo) => todo.isCompleted).toList();
  
  List<Todo> get incompleteTodos => 
      _todos.where((todo) => !todo.isCompleted).toList();

  int get completionPercentage {
    if (_todos.isEmpty) return 0;
    final completed = completedTodos.length;
    return ((completed / _todos.length) * 100).round();
  }

  Future<void> loadTodayTodos() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📋 Loading today\'s todos...');
      _todos = await _supabaseService.getTodayTodos();
      print('✅ Loaded ${_todos.length} todos');
      
      _todayReflection = await _supabaseService.getReflection(DateTime.now());
      if (_todayReflection != null) {
        print('📝 Loaded reflection: Morning=${_todayReflection!.morningIntention != null}, Evening=${_todayReflection!.eveningReflection != null}');
      } else {
        print('📝 No reflection found for today');
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading todos: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadTodos({DateTime? date}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _todos = await _supabaseService.getTodos(date: date);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<List<Todo>> loadCompletedTodos() async {
    try {
      return await _supabaseService.getCompletedTodos();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> createTodo(String task, {DateTime? dueDate}) async {
    try {
      await _supabaseService.createTodo(task, dueDate: dueDate);
      await loadTodayTodos();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTodo(String todoId, bool isCompleted) async {
    try {
      await _supabaseService.toggleTodo(todoId, isCompleted);
      await loadTodayTodos();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _supabaseService.deleteTodo(todoId);
      await loadTodayTodos();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateMorningIntention(String intention) async {
    try {
      await _supabaseService.upsertReflection(
        date: DateTime.now(),
        morningIntention: intention,
        eveningReflection: _todayReflection?.eveningReflection,
      );
      
      _todayReflection = await _supabaseService.getReflection(DateTime.now());
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEveningReflection(String reflection) async {
    try {
      await _supabaseService.upsertReflection(
        date: DateTime.now(),
        morningIntention: _todayReflection?.morningIntention,
        eveningReflection: reflection,
      );
      
      _todayReflection = await _supabaseService.getReflection(DateTime.now());
      notifyListeners();
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
