class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String category;
  final bool isCompleted;
  final int progress; // 0-100 percentage
  final String? notes;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.targetDate,
    required this.category,
    this.isCompleted = false,
    this.progress = 0,
    this.notes,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'targetDate': targetDate?.millisecondsSinceEpoch,
      'category': category,
      'isCompleted': isCompleted ? 1 : 0,
      'progress': progress,
      'notes': notes,
    };
  }

  // Create from Map
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      targetDate: map['targetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['targetDate'])
          : null,
      category: map['category'],
      isCompleted: map['isCompleted'] == 1,
      progress: map['progress'],
      notes: map['notes'],
    );
  }

  // Create a copy with updated fields
  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? targetDate,
    String? category,
    bool? isCompleted,
    int? progress,
    String? notes,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, description: $description, progress: $progress%)';
  }
}
