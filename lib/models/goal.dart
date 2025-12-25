class Goal {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? category; // Health, Career, Personal
  final DateTime? targetDate;
  final int progress; // 0-100
  final int streakCount;
  final DateTime? lastStreakDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category,
    this.targetDate,
    this.progress = 0,
    this.streakCount = 0,
    this.lastStreakDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      targetDate: json['target_date'] != null 
          ? DateTime.parse(json['target_date'] as String) 
          : null,
      progress: json['progress'] as int? ?? 0,
      streakCount: json['streak_count'] as int? ?? 0,
      lastStreakDate: json['last_streak_date'] != null 
          ? DateTime.parse(json['last_streak_date'] as String) 
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'target_date': targetDate?.toIso8601String(),
      'progress': progress,
      'streak_count': streakCount,
      'last_streak_date': lastStreakDate?.toIso8601String(),
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? targetDate,
    int? progress,
    int? streakCount,
    DateTime? lastStreakDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      streakCount: streakCount ?? this.streakCount,
      lastStreakDate: lastStreakDate ?? this.lastStreakDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
