import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/supabase_service.dart';

class GoalsProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Goal> getGoalsByCategory(String category) {
    return _goals.where((goal) => goal.category == category).toList();
  }

  Map<String, List<Goal>> get goalsByCategory {
    final Map<String, List<Goal>> categorized = {};
    for (var goal in _goals) {
      final category = goal.category ?? 'Other';
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(goal);
    }
    return categorized;
  }

  int getCategoryProgress(String category) {
    final categoryGoals = getGoalsByCategory(category);
    if (categoryGoals.isEmpty) return 0;
    
    final totalProgress = categoryGoals.fold<int>(
      0,
      (sum, goal) => sum + goal.progress,
    );
    
    return (totalProgress / categoryGoals.length).round();
  }

  Future<void> loadGoals() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🎯 Loading goals...');
      _goals = await _supabaseService.getGoals();
      print('✅ Loaded ${_goals.length} goals');

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading goals: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createGoal({
    required String title,
    String? description,
    String? category,
    DateTime? targetDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.createGoal(
        title: title,
        description: description,
        category: category,
        targetDate: targetDate,
      );

      await loadGoals();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGoal(
    String goalId, {
    String? title,
    String? description,
    String? category,
    int? progress,
    bool? isCompleted,
  }) async {
    try {
      await _supabaseService.updateGoal(
        goalId,
        title: title,
        description: description,
        category: category,
        progress: progress,
        isCompleted: isCompleted,
      );

      await loadGoals();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGoalProgress(String goalId, int progress) async {
    try {
      // Automatically mark as completed when progress reaches 100%
      await _supabaseService.updateGoal(
        goalId, 
        progress: progress,
        isCompleted: progress >= 100,
      );
      await loadGoals();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateGoalStreak(String goalId) async {
    try {
      await _supabaseService.updateGoalStreak(goalId);
      await loadGoals();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _supabaseService.deleteGoal(goalId);
      await loadGoals();
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
