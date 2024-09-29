class Task {
  int? id; // Nullable ID
  String title;
  bool done;
  DateTime deadline;

  // Constructor with optional commentCount, defaulting to 0
  Task({
    this.id,
    required this.title,
    this.done = false,
    required this.deadline,
  });

  // Method to convert Task object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'done': done ? 1 : 0,
      'deadline': deadline.toIso8601String(),
    };
  }

  // Method to create Task object from Map
  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      done: map['done'] == 1,
      deadline: DateTime.parse(map['deadline']),
    );
  }
}
