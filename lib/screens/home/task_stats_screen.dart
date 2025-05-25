import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/models/task_model.dart';

class TaskStatsScreen extends StatelessWidget {
  const TaskStatsScreen({super.key});
  final bool useFirestore = true;

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final user = FirebaseAuth.instance.currentUser;

    if (useFirestore) {
      if (user == null) {
        return const Scaffold(body: Center(child: Text("User not logged in")));
      }

      return Scaffold(
        appBar: AppBar(title: const Text("Task Stats")),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('tasks')
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks =
                snapshot.data!.docs.map((doc) {
                  final map = doc.data() as Map<String, dynamic>;
                  return TaskModel.fromMap({...map, 'id': doc.id});
                }).toList();

            return _buildStats(tasks);
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("Task Stats")),
        body: Obx(() => _buildStats(taskController.taskList)),
      );
    }
  }

  Widget _buildStats(List<TaskModel> tasks) {
    final now = DateTime.now();

    final today =
        tasks.where((task) {
          final date = DateTime.tryParse(task.date);
          return task.isDone == 1 &&
              date != null &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).length;

    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final week =
        tasks.where((task) {
          final date = DateTime.tryParse(task.date);
          return task.isDone == 1 &&
              date != null &&
              !date.isBefore(weekStart) &&
              !date.isAfter(weekEnd);
        }).length;

    final totalCompleted = tasks.where((task) => task.isDone == 1).length;
    final totalPending = tasks.where((task) => task.isDone == 0).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _statTile("✅ Completed Today", today, Icons.today, Colors.green),
          const SizedBox(height: 20),
          _statTile(
            "📅 Completed This Week",
            week,
            Icons.calendar_view_week,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _statTile(
            "🏁 Total Completed",
            totalCompleted,
            Icons.check_circle,
            Colors.purple,
          ),
          const SizedBox(height: 20),
          _statTile(
            "🕒 Pending Tasks",
            totalPending,
            Icons.pending_actions,
            Colors.orange,
          ),
        ],
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
