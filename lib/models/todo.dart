class Todo {
  final String id;
  final String userId;
  final String task;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime dueDate;

  Todo({
    required this.id,
    required this.userId,
    required this.task,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.dueDate,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      task: json['task'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task': task,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate.toIso8601String().split('T')[0], // Date only
    };
  }

  Todo copyWith({
    String? id,
    String? userId,
    String? task,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      task: task ?? this.task,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
