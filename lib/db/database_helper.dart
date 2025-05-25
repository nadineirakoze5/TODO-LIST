import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final _firestore = FirebaseFirestore.instance;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        date TEXT,
        time TEXT,
        priority TEXT,
        category TEXT,
        repeat TEXT,
        checklist TEXT,
        isDone INTEGER
      )
    ''');
  }

  /// ================= SQLite Operations =================

  Future<int> insertTask(TaskModel task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toSqliteMap());
  }

  Future<List<TaskModel>> getTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((map) => TaskModel.fromSqlite(map)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    final db = await instance.database;
    if (task.localId == null) return 0;
    return await db.update(
      'tasks',
      task.toSqliteMap(),
      where: 'id = ?',
      whereArgs: [task.localId],
    );
  }

  Future<int> deleteTask(int localId) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [localId]);
  }

  Future<void> clearTasks() async {
    final db = await instance.database;
    await db.delete('tasks');
  }

  /// ================= Firestore Operations =================

  Future<void> insertTaskToFirestore(TaskModel task) async {
    await _firestore.collection('tasks').add(task.toMap());
  }

  Future<List<TaskModel>> getTasksFromFirestore() async {
    final snapshot = await _firestore.collection('tasks').get();
    return snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Future<void> updateTaskInFirestore(TaskModel task) async {
    if (task.id == null) return;
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  Future<void> deleteTaskFromFirestore(String id) async {
    await _firestore.collection('tasks').doc(id).delete();
  }

  Future<void> clearTasksInFirestore() async {
    final snapshot = await _firestore.collection('tasks').get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// ================= Combined Helpers =================

  Future<void> insertTaskToBoth(TaskModel task) async {
    await insertTask(task);
    await insertTaskToFirestore(task);
  }

  Future<void> updateTaskInBoth(TaskModel task) async {
    await updateTask(task);
    await updateTaskInFirestore(task);
  }

  Future<void> deleteTaskFromBoth(TaskModel task) async {
    if (task.localId != null) await deleteTask(task.localId!);
    if (task.id != null) await deleteTaskFromFirestore(task.id!);
  }
}
