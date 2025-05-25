import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/screens/task/add_edit_task_screen.dart';
import 'package:todo_list/screens/task/task_detail_screen.dart';



class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({super.key});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  final TaskController taskController = Get.find();
  String searchQuery = "";
  final bool useFirestore = true; // Change to false to use SQLite

  @override
  void initState() {
    super.initState();
    if (!useFirestore) {
      taskController.fetchTasks(); // Only fetch from SQLite
    }
  }

  void _confirmDelete(String id) {
    Get.defaultDialog(
      title: "Delete Task",
      middleText: "Are you sure you want to delete this task?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        if (useFirestore) {
          await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
        } else {
          await taskController.deleteTask(int.parse(id));
        }
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tasks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged:
                  (val) => setState(() => searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search by title or description...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: useFirestore ? _buildFirestoreTasks() : _buildSQLiteTasks(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddEditTaskScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSQLiteTasks() {
    return Obx(() {
      final tasks =
          taskController.taskList.where((task) {
            final q = searchQuery.toLowerCase();
            return task.title.toLowerCase().contains(q) ||
                task.description.toLowerCase().contains(q);
          }).toList();

      if (tasks.isEmpty) {
        return const Center(child: Text('No tasks found.'));
      }

      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(task);
        },
      );
    });
  }

  Widget _buildFirestoreTasks() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No tasks found"));
        }

        final tasks =
            snapshot.data!.docs
                .map(
                  (doc) => TaskModel.fromMap({
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  }),
                )
                .where((task) {
                  final q = searchQuery.toLowerCase();
                  return task.title.toLowerCase().contains(q) ||
                      task.description.toLowerCase().contains(q);
                })
                .toList();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => _buildTaskCard(tasks[index]),
        );
      },
    );
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
        leading: Checkbox(
          value: task.isDone == 1,
          onChanged: (val) {
            final updated = task.copyWith(isDone: val! ? 1 : 0);
            if (useFirestore) {
              FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(task.id)
                  .update({'isDone': updated.isDone});
            } else {
              taskController.updateTask(updated);
            }
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => Get.to(() => AddEditTaskScreen(task: task)),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(task.id!),
            ),
          ],
        ),
      ),
    );
  }
}
