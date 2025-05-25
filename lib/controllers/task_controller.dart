import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/task_model.dart';
import '../db/database_helper.dart';

class TaskController extends GetxController {
  var taskList = <TaskModel>[].obs;

  /// ✅ Load from SQLite (local)
  Future<void> fetchTasks() async {
    final data = await DatabaseHelper.instance.getTasks();
    taskList.assignAll(data);
  }

  /// ✅ Insert only in SQLite
  Future<void> addTask(TaskModel task) async {
    await DatabaseHelper.instance.insertTask(task);
    fetchTasks();
  }

  /// ✅ Update only in SQLite
  Future<void> updateTask(TaskModel task) async {
    await DatabaseHelper.instance.updateTask(task);
    fetchTasks();
  }

  /// ✅ Delete from SQLite only
  Future<void> deleteTask(int localId) async {
    await DatabaseHelper.instance.deleteTask(localId);
    fetchTasks();
  }

  /// ✅ Delete multiple from SQLite
  Future<void> deleteMultiple(List<int> ids) async {
    for (int id in ids) {
      await DatabaseHelper.instance.deleteTask(id);
    }
    fetchTasks();
  }

  /// ✅ Add to both Firestore and SQLite
  Future<void> addTaskToBoth(TaskModel task) async {
    final docRef = await FirebaseFirestore.instance
        .collection('tasks')
        .add(task.toMap());

    final syncedTask = task.copyWith(id: docRef.id);
    await DatabaseHelper.instance.insertTask(syncedTask);

    fetchTasks();
  }

  /// ✅ Update in both Firestore and SQLite
  Future<void> updateTaskToBoth(TaskModel task) async {
    if (task.id != null) {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
    }

    if (task.localId != null) {
      await DatabaseHelper.instance.updateTask(task);
    }

    fetchTasks();
  }

  /// ✅ Delete from both Firestore and SQLite
  Future<void> deleteTaskFromBoth(TaskModel task) async {
    // Firestore
    if (task.id != null) {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .delete();
    }

    // SQLite
    if (task.localId != null) {
      await DatabaseHelper.instance.deleteTask(task.localId!);
    }

    fetchTasks();
  }
}
