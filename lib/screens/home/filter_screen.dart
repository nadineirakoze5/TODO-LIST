import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/screens/task/task_detail_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TaskController taskController = Get.find();
  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    taskController.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showCompleted ? 'Completed Tasks' : 'Pending Tasks'),
        actions: [
          IconButton(
            icon: Icon(
              showCompleted ? Icons.incomplete_circle : Icons.check_circle,
            ),
            tooltip: showCompleted ? 'Show Pending' : 'Show Completed',
            onPressed: () {
              setState(() => showCompleted = !showCompleted);
            },
          ),
        ],
      ),
      body: Obx(() {
        final tasks =
            taskController.taskList
                .where(
                  (task) => showCompleted ? task.isDone == 1 : task.isDone == 0,
                )
                .toList();

        if (tasks.isEmpty) {
          return Center(
            child: Text('No ${showCompleted ? 'completed' : 'pending'} tasks.'),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            TaskModel task = tasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                onTap:
                    () => Get.to(
                      () => TaskDetailScreen(task: task),
                    ), // ✅ Open detail
                title: Text(task.title),
                subtitle: Text(
                  'Due: ${DateFormat.yMd().format(DateTime.parse(task.date))}',
                ),

                trailing: Checkbox(
                  value: task.isDone == 1,
                  onChanged: (val) {
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
                      isDone: val! ? 1 : 0,
                    );
                    taskController.updateTask(updatedTask);
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
