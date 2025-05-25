import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import '../screens/task/add_edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  void _deleteTask(BuildContext context) {
    if (task.id == null) {
      Get.snackbar("Error", "Task ID is null, can't delete.");
      return;
    }

    // Handle Firestore or SQLite deletion
    if (task.id is String && task.id!.length == 20) {
      // Firestore ID (usually a long string)
      FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
    } else {
      // SQLite ID (numeric stored as String)
      final TaskController controller = Get.find();
      controller.deleteTask(int.tryParse(task.id!) ?? -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.find();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone == 1 ? TextDecoration.lineThrough : null,
            color: task.isDone == 1 ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'Due: ${DateFormat.yMd().format(DateTime.parse(task.date))}',
        ),
        leading: Checkbox(
          value: task.isDone == 1,
          onChanged: (value) {
            final updated = task.copyWith(isDone: value! ? 1 : 0);
            if (task.id is String && task.id!.length == 20) {
              FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(task.id)
                  .update({'isDone': updated.isDone});
            } else {
              controller.updateTask(updated);
            }
          },
        ),
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => Get.to(() => AddEditTaskScreen(task: task)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(context),
            ),
          ],
        ),
      ),
    );
  }
}
