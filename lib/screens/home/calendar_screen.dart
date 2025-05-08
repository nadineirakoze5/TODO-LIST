import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/screens/task/task_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskController taskController = Get.find();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    taskController.fetchTasks();
  }

  List<TaskModel> _getTasksForDay(DateTime day) {
    return taskController.taskList.where((task) {
      final taskDate = DateTime.parse(task.date);
      return taskDate.year == day.year &&
          taskDate.month == day.month &&
          taskDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final tasks = _getTasksForDay(_selectedDay);
              if (tasks.isEmpty) {
                return const Center(child: Text("No tasks for selected day."));
              }
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(
                        '${DateFormat.Hm().format(DateFormat('HH:mm').parse(task.time))} | ${task.priority} • ${task.category}',
                      ),
                      onTap: () => Get.to(() => TaskDetailScreen(task: task)),
                      trailing: Icon(
                        task.isDone == 1
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: task.isDone == 1 ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
