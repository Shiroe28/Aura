class DailyReflection {
  final String id;
  final String userId;
  final DateTime reflectionDate;
  final String? morningIntention;
  final String? eveningReflection;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyReflection({
    required this.id,
    required this.userId,
    required this.reflectionDate,
    this.morningIntention,
    this.eveningReflection,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyReflection.fromJson(Map<String, dynamic> json) {
    return DailyReflection(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      reflectionDate: DateTime.parse(json['reflection_date'] as String),
      morningIntention: json['morning_intention'] as String?,
      eveningReflection: json['evening_reflection'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reflection_date': reflectionDate.toIso8601String().split('T')[0],
      'morning_intention': morningIntention,
      'evening_reflection': eveningReflection,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DailyReflection copyWith({
    String? id,
    String? userId,
    DateTime? reflectionDate,
    String? morningIntention,
    String? eveningReflection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyReflection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reflectionDate: reflectionDate ?? this.reflectionDate,
      morningIntention: morningIntention ?? this.morningIntention,
      eveningReflection: eveningReflection ?? this.eveningReflection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
