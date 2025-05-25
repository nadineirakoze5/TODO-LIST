import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../db/database_helper.dart';

class TaskController extends GetxController {
  var taskList = <TaskModel>[].obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Load tasks from Firestore (per user)
  Future<void> fetchTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('date')
        .get();

    final tasks = snapshot.docs
        .map((doc) => TaskModel.fromMap(doc.data(), id: doc.id))
        .toList();

    taskList.assignAll(tasks);
  }

  /// ✅ Add task to Firestore (per user) + optional SQLite
  Future<void> addTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add(task.toMap());

    final syncedTask = task.copyWith(id: docRef.id);
    await DatabaseHelper.instance.insertTask(syncedTask); // optional local save

    fetchTasks();
  }

  /// ✅ Update task in both Firestore and SQLite
  Future<void> updateTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (task.id != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
    }

    if (task.localId != null) {
      await DatabaseHelper.instance.updateTask(task);
    }

    fetchTasks();
  }

  ///  Delete task from both Firestore and SQLite
  Future<void> deleteTask(TaskModel task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (task.id != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .delete();
    }

    if (task.localId != null) {
      await DatabaseHelper.instance.deleteTask(task.localId!);
    }

    fetchTasks();
  }

  ///  Delete multiple tasks
  Future<void> deleteMultiple(List<TaskModel> tasks) async {
    for (final task in tasks) {
      await deleteTask(task);
    }
  }
}
