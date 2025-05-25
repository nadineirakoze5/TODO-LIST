import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final int? localId; // For SQLite
  final String? id; // For Firestore
  final String title;
  final String description;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String priority;
  final String category;
  final String repeat;
  final String checklist; // JSON string of list
  final int isDone; // 0 or 1

  TaskModel({
    this.localId,
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

  /// 🔄 Convert to Map for Firestore
  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'date': date, // string format (not Timestamp)
    'time': time,
    'priority': priority,
    'category': category,
    'repeat': repeat,
    'checklist': checklist,
    'isDone': isDone,
  };

  /// 🔄 Create from Firestore Map
  factory TaskModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final dateVal = map['date'];
    final String dateString =
        dateVal is Timestamp
            ? dateVal.toDate().toIso8601String().split('T')[0]
            : dateVal.toString();

    return TaskModel(
      id: id ?? map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: dateString,
      time: map['time'] ?? '',
      priority: map['priority'] ?? 'Medium',
      category: map['category'] ?? 'General',
      repeat: map['repeat'] ?? 'None',
      checklist: map['checklist'] ?? '[]',
      isDone: map['isDone'] ?? 0,
    );
  }

  /// 🔄 Convert to Map for SQLite
  Map<String, dynamic> toSqliteMap() => {
    'id': localId,
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

  /// 🔄 Create from SQLite Map
  factory TaskModel.fromSqlite(Map<String, dynamic> map) => TaskModel(
    localId: map['id'],
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    date: map['date'] ?? '',
    time: map['time'] ?? '',
    priority: map['priority'] ?? 'Medium',
    category: map['category'] ?? 'General',
    repeat: map['repeat'] ?? 'None',
    checklist: map['checklist'] ?? '[]',
    isDone: map['isDone'] ?? 0,
  );

  /// 📝 Copy method for task updates
  TaskModel copyWith({
    int? localId,
    String? id,
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
      localId: localId ?? this.localId,
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
