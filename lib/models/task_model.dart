class TaskModel {
  final int? id;
  final String title;
  final String description;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String priority; // High, Medium, Low
  final String category;
  final String repeat; // None, Daily, Weekly, Monthly
  final String checklist; // JSON-encoded List<String>
  final int isDone;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.priority,
    required this.category,
    required this.repeat,
    required this.checklist,
    required this.isDone,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date,
    'time': time,
    'priority': priority,
    'category': category,
    'repeat': repeat,
    'checklist': checklist,
    'isDone': isDone,
  };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    date: map['date'],
    time: map['time'],
    priority: map['priority'],
    category: map['category'],
    repeat: map['repeat'],
    checklist: map['checklist'],
    isDone: map['isDone'],
  );

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? priority,
    String? category,
    String? repeat,
    String? checklist,
    int? isDone,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      repeat: repeat ?? this.repeat,
      checklist: checklist ?? this.checklist,
      isDone: isDone ?? this.isDone,
    );
  }
}
