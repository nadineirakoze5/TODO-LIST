import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final checklist = List<String>.from(json.decode(task.checklist));

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat.yMMMMd().format(DateTime.parse(task.date)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 6),
                      Text(task.time),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(task.description, style: textTheme.bodyMedium),
                  const Divider(height: 30),

                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text("Priority: ${task.priority}")),
                      Chip(label: Text("Category: ${task.category}")),
                      if (task.repeat != 'None')
                        Chip(label: Text("Repeat: ${task.repeat}")),
                    ],
                  ),

                  const SizedBox(height: 20),
                  if (checklist.isNotEmpty) ...[
                    const Text(
                      "Checklist",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          checklist
                              .map(
                                (item) => Row(
                                  children: [
                                    const Icon(
                                      Icons.check_box_outline_blank,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(item)),
                                  ],
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
