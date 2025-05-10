import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/models/task_model.dart';

class TaskStatsScreen extends StatelessWidget {
  const TaskStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final now = DateTime.now();

    final today =
        taskController.taskList.where((task) {
          final date = DateTime.parse(task.date);
          return task.isDone == 1 &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).length;

    final weekStart = now.subtract(Duration(days: now.weekday));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final week =
        taskController.taskList.where((task) {
          final date = DateTime.parse(task.date);
          return task.isDone == 1 &&
              date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              date.isBefore(weekEnd.add(const Duration(days: 1)));
        }).length;

    final total = taskController.taskList.where((t) => t.isDone == 1).length;

    return Scaffold(
      appBar: AppBar(title: const Text("Task Stats")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _statTile("Completed Today", today, Icons.today, Colors.green),
            const SizedBox(height: 20),
            _statTile(
              "📅 This Week",
              week,
              Icons.calendar_view_week,
              Colors.blue,
            ),
            const SizedBox(height: 20),
            _statTile(
              "🏁 Total Completed",
              total,
              Icons.check_circle,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
