import 'package:get/get.dart';
import '../models/task_model.dart';
import '../db/database_helper.dart';

class TaskController extends GetxController {
  var taskList = <TaskModel>[].obs;

  Future<void> fetchTasks() async {
    final data = await DatabaseHelper.instance.getTasks();
    taskList.assignAll(data);
  }

  Future<void> addTask(TaskModel task) async {
    await DatabaseHelper.instance.insertTask(task);
    fetchTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await DatabaseHelper.instance.updateTask(task);
    fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    fetchTasks();
  }

  Future<void> deleteMultiple(List<int> ids) async {
    for (int id in ids) {
      await DatabaseHelper.instance.deleteTask(id);
    }
    fetchTasks();
  }
}
