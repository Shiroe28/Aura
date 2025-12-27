import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/goal.dart';
import '../models/todo.dart';
import '../models/calendar_event.dart';
import '../models/daily_reflection.dart';
import '../models/journal_entry.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  // ==================== Authentication ====================

  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ==================== User Profile ====================

  Future<UserProfile?> getProfile() async {
    if (currentUserId == null) return null;

    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', currentUserId!)
          .maybeSingle();

      if (response == null) {
        print('⚠️ No profile found for user $currentUserId');
        return null;
      }

      print('✅ Profile fetched: ${response}');
      return UserProfile.fromJson(response);
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }

  Future<void> updateProfile(String username, String? avatarUrl) async {
    if (currentUserId == null) return;

    print('💾 Updating profile: username=$username, avatarUrl=$avatarUrl');

    final result = await client.from('profiles').upsert({
      'id': currentUserId,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).select();

    print('✅ Profile update result: $result');
  }

  // ==================== Goals ====================

  Future<List<Goal>> getGoals() async {
    if (currentUserId == null) {
      print('⚠️ getGoals: No user authenticated');
      return [];
    }

    print('🔍 Fetching goals for user: $currentUserId');
    final response = await client
        .from('goals')
        .select()
        .eq('user_id', currentUserId!)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Goal.fromJson(json)).toList();
  }

  Future<List<Goal>> getGoalsByCategory(String category) async {
    if (currentUserId == null) return [];

    final response = await client
        .from('goals')
        .select()
        .eq('user_id', currentUserId!)
        .eq('category', category)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Goal.fromJson(json)).toList();
  }

  Future<Goal> createGoal({
    required String title,
    String? description,
    String? category,
    DateTime? targetDate,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final response = await client.from('goals').insert({
      'user_id': currentUserId,
      'title': title,
      'description': description,
      'category': category,
      'target_date': targetDate?.toIso8601String().split('T')[0],
    }).select().single();

    return Goal.fromJson(response);
  }

  Future<void> updateGoal(String goalId, {
    String? title,
    String? description,
    String? category,
    int? progress,
    int? streakCount,
    DateTime? lastStreakDate,
    bool? isCompleted,
  }) async {
    final Map<String, dynamic> updates = {};
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (category != null) updates['category'] = category;
    if (progress != null) updates['progress'] = progress;
    if (streakCount != null) updates['streak_count'] = streakCount;
    if (lastStreakDate != null) {
      updates['last_streak_date'] = lastStreakDate.toIso8601String().split('T')[0];
    }
    if (isCompleted != null) updates['is_completed'] = isCompleted;

    await client.from('goals').update(updates).eq('id', goalId);
  }

  Future<void> deleteGoal(String goalId) async {
    await client.from('goals').delete().eq('id', goalId);
  }

  Future<void> updateGoalStreak(String goalId) async {
    final goal = await client
        .from('goals')
        .select()
        .eq('id', goalId)
        .single();

    final lastStreakDate = goal['last_streak_date'] != null
        ? DateTime.parse(goal['last_streak_date'])
        : null;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    int newStreakCount = goal['streak_count'] ?? 0;

    if (lastStreakDate == null || 
        lastStreakDate.difference(today).inDays.abs() > 1) {
      // Start new streak
      newStreakCount = 1;
    } else if (lastStreakDate.day == yesterday.day) {
      // Continue streak
      newStreakCount++;
    }

    await updateGoal(
      goalId,
      streakCount: newStreakCount,
      lastStreakDate: today,
    );
  }

  // ==================== Todos ====================

  Future<List<Todo>> getTodos({DateTime? date}) async {
    if (currentUserId == null) {
      print('⚠️ getTodos: No user authenticated');
      return [];
    }

    print('🔍 Fetching todos for user: $currentUserId${date != null ? " on $date" : ""}');
    var query = client
        .from('todos')
        .select()
        .eq('user_id', currentUserId!);

    if (date != null) {
      query = query.eq('due_date', date.toIso8601String().split('T')[0]);
    }

    final response = await query.order('created_at', ascending: false);

    return (response as List).map((json) => Todo.fromJson(json)).toList();
  }

  Future<List<Todo>> getTodayTodos() async {
    return await getTodos(date: DateTime.now());
  }

  Future<List<Todo>> getCompletedTodos() async {
    if (currentUserId == null) return [];

    final response = await client
        .from('todos')
        .select()
        .eq('user_id', currentUserId!)
        .eq('is_completed', true)
        .order('completed_at', ascending: false);

    return (response as List).map((json) => Todo.fromJson(json)).toList();
  }

  Future<Todo> createTodo(String task, {DateTime? dueDate}) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final response = await client.from('todos').insert({
      'user_id': currentUserId,
      'task': task,
      'due_date': (dueDate ?? DateTime.now()).toIso8601String().split('T')[0],
    }).select().single();

    return Todo.fromJson(response);
  }

  Future<void> toggleTodo(String todoId, bool isCompleted) async {
    await client.from('todos').update({
      'is_completed': isCompleted,
      'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
    }).eq('id', todoId);
  }

  Future<void> deleteTodo(String todoId) async {
    await client.from('todos').delete().eq('id', todoId);
  }

  // ==================== Calendar Events ====================

  Future<List<CalendarEvent>> getEvents({DateTime? date}) async {
    if (currentUserId == null) return [];

    var query = client
        .from('calendar_events')
        .select()
        .eq('user_id', currentUserId!);

    if (date != null) {
      query = query.eq('event_date', date.toIso8601String().split('T')[0]);
    }

    final response = await query.order('event_date', ascending: true);

    return (response as List)
        .map((json) => CalendarEvent.fromJson(json))
        .toList();
  }

  Future<Map<DateTime, List<CalendarEvent>>> getEventsForMonth(
      int year, int month) async {
    if (currentUserId == null) {
      print('⚠️ getEventsForMonth: No user authenticated');
      return {};
    }

    print('🔍 Fetching events for $year-$month, user: $currentUserId');
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final response = await client
        .from('calendar_events')
        .select()
        .eq('user_id', currentUserId!)
        .gte('event_date', firstDay.toIso8601String().split('T')[0])
        .lte('event_date', lastDay.toIso8601String().split('T')[0]);

    final events = (response as List)
        .map((json) => CalendarEvent.fromJson(json))
        .toList();

    final Map<DateTime, List<CalendarEvent>> eventMap = {};
    for (var event in events) {
      final date = DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
      );
      if (!eventMap.containsKey(date)) {
        eventMap[date] = [];
      }
      eventMap[date]!.add(event);
    }

    return eventMap;
  }

  Future<CalendarEvent> createEvent({
    required String eventName,
    String? eventDescription,
    required DateTime eventDate,
    String? eventTime,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final response = await client.from('calendar_events').insert({
      'user_id': currentUserId,
      'event_name': eventName,
      'event_description': eventDescription,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'event_time': eventTime,
    }).select().single();

    return CalendarEvent.fromJson(response);
  }

  Future<void> updateEvent(String eventId, {
    String? eventName,
    String? eventDescription,
    DateTime? eventDate,
    String? eventTime,
    bool? isCompleted,
  }) async {
    final Map<String, dynamic> updates = {};
    if (eventName != null) updates['event_name'] = eventName;
    if (eventDescription != null) updates['event_description'] = eventDescription;
    if (eventDate != null) {
      updates['event_date'] = eventDate.toIso8601String().split('T')[0];
    }
    if (eventTime != null) updates['event_time'] = eventTime;
    if (isCompleted != null) updates['is_completed'] = isCompleted;

    await client.from('calendar_events').update(updates).eq('id', eventId);
  }

  Future<void> deleteEvent(String eventId) async {
    await client.from('calendar_events').delete().eq('id', eventId);
  }

  // ==================== Daily Reflections ====================

  Future<DailyReflection?> getReflection(DateTime date) async {
    if (currentUserId == null) return null;

    try {
      final response = await client
          .from('daily_reflections')
          .select()
          .eq('user_id', currentUserId!)
          .eq('reflection_date', date.toIso8601String().split('T')[0])
          .maybeSingle();

      if (response == null) return null;
      return DailyReflection.fromJson(response);
    } catch (e) {
      print('Error fetching reflection: $e');
      return null;
    }
  }

  Future<DailyReflection> upsertReflection({
    required DateTime date,
    String? morningIntention,
    String? eveningReflection,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final response = await client.from('daily_reflections').upsert(
      {
        'user_id': currentUserId,
        'reflection_date': date.toIso8601String().split('T')[0],
        'morning_intention': morningIntention,
        'evening_reflection': eveningReflection,
      },
      onConflict: 'user_id,reflection_date',
    ).select().single();

    return DailyReflection.fromJson(response);
  }

  // ==================== Journal Entries ====================

  Future<List<JournalEntry>> getJournalEntries() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final response = await client
          .from('journal_entries')
          .select()
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((entry) => JournalEntry.fromJson(entry))
          .toList();
    } catch (e) {
      print('Error fetching journal entries: $e');
      rethrow;
    }
  }

  Future<JournalEntry> createJournalEntry({
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final entryId = const Uuid().v4();
    final now = DateTime.now();

    final response = await client.from('journal_entries').insert({
      'id': entryId,
      'user_id': currentUserId,
      'title': title,
      'content': content,
      'tags': tags,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    }).select().single();

    return JournalEntry.fromJson(response);
  }

  Future<JournalEntry> updateJournalEntry({
    required String entryId,
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;
    if (tags != null) updates['tags'] = tags;

    final response = await client
        .from('journal_entries')
        .update(updates)
        .eq('id', entryId)
        .eq('user_id', currentUserId!)
        .select()
        .single();

    return JournalEntry.fromJson(response);
  }

  Future<void> deleteJournalEntry(String entryId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await client
        .from('journal_entries')
        .delete()
        .eq('id', entryId)
        .eq('user_id', currentUserId!);
  }
}
