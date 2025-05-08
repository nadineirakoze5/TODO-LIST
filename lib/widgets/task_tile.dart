import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import '../screens/task/add_edit_task_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

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
            final updatedTask = TaskModel(
              id: task.id,
              title: task.title,
              description: task.description,
              date: task.date,
              time: task.time,
              priority: task.priority,
              category: task.category,
              repeat: task.repeat,
              checklist: task.checklist,
              isDone: value! ? 1 : 0,
            );
            controller.updateTask(updatedTask);
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
              onPressed: () => controller.deleteTask(task.id!),
            ),
          ],
        ),
      ),
    );
  }
}
