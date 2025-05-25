import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool showCompleted = false;
  final bool useFirestore = true;

  @override
  void initState() {
    super.initState();
    if (!useFirestore) {
      taskController.fetchTasks();
    }
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
            onPressed: () => setState(() => showCompleted = !showCompleted),
          ),
        ],
      ),
      body: useFirestore ? _buildFirestoreTasks() : _buildSQLiteTasks(),
    );
  }

  Widget _buildFirestoreTasks() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    final stream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .where('isDone', isEqualTo: showCompleted ? 1 : 0)
            .orderBy('date')
            .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks =
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return TaskModel.fromMap({...data, 'id': doc.id});
            }).toList();

        if (tasks.isEmpty) {
          return Center(
            child: Text("No ${showCompleted ? 'completed' : 'pending'} tasks."),
          );
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
        );
      },
    );
  }

  Widget _buildSQLiteTasks() {
    return Obx(() {
      final tasks =
          taskController.taskList
              .where(
                (task) => showCompleted ? task.isDone == 1 : task.isDone == 0,
              )
              .toList();

      if (tasks.isEmpty) {
        return Center(
          child: Text("No ${showCompleted ? 'completed' : 'pending'} tasks."),
        );
      }

      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
      );
    });
  }

  Widget _buildTaskCard(TaskModel task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: () => Get.to(() => TaskDetailScreen(task: task)),
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
        trailing: Checkbox(
          value: task.isDone == 1,
          onChanged: (val) {
            final updated = task.copyWith(isDone: val! ? 1 : 0);
            if (useFirestore) {
              final user = _auth.currentUser;
              if (user != null && task.id != null) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('tasks')
                    .doc(task.id)
                    .update({'isDone': updated.isDone});
              }
            } else {
              taskController.updateTask(updated);
            }
          },
        ),
      ),
    );
  }
}
