class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String goalId; // Reference to the goal this activity contributes to
  final int duration; // Duration in minutes
  final String category;
  final String? notes;
  final bool isCompleted;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.goalId,
    this.duration = 0,
    required this.category,
    this.notes,
    this.isCompleted = true,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'goalId': goalId,
      'duration': duration,
      'category': category,
      'notes': notes,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Create from Map
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      goalId: map['goalId'],
      duration: map['duration'],
      category: map['category'],
      notes: map['notes'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Create a copy with updated fields
  Activity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? goalId,
    int? duration,
    String? category,
    String? notes,
    bool? isCompleted,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      goalId: goalId ?? this.goalId,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, date: $date, goalId: $goalId)';
  }
}

