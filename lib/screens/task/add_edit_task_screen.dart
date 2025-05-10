import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/controllers/task_controller.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _subtaskController = TextEditingController();
  final _controller = Get.find<TaskController>();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _priority = 'Medium';
  String _repeat = 'None';
  String _category = 'General';
  List<String> _checklist = [];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _selectedDate = DateTime.tryParse(t.date);

      // Safely parse time in 24-hour format
      try {
        final parts = t.time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        _selectedTime = TimeOfDay.now(); // silently fallback without toast
      }

      _priority = t.priority;
      _repeat = t.repeat;
      _category = t.category;

      try {
        _checklist = List<String>.from(json.decode(t.checklist));
      } catch (_) {
        _checklist = [];
      }
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      Fluttertoast.showToast(msg: "Please fill all required fields");
      return;
    }

    // Convert TimeOfDay to 24-hour formatted string
    final formattedTime =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    final task = TaskModel(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      date: _selectedDate!.toIso8601String(),
      time: formattedTime,
      priority: _priority,
      category: _category,
      repeat: _repeat,
      checklist: json.encode(_checklist),
      isDone: widget.task?.isDone ?? 0,
    );

    if (widget.task == null) {
      await _controller.addTask(task);

      await NotificationService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "Task Reminder",
        body: task.title,
        scheduledTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
      );

      Fluttertoast.showToast(msg: "✅ Task created!");
    } else {
      await _controller.updateTask(task);
      Fluttertoast.showToast(msg: "✅ Task updated!");
    }

    await _controller.fetchTasks(); // Ensure list refresh
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Task" : "Add Task")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate == null
                          ? 'Pick a date'
                          : DateFormat.yMMMMd().format(_selectedDate!),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTime == null
                          ? 'Pick a time'
                          : _selectedTime!.format(context),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _pickTime,
                      child: const Text("Pick Time"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items:
                      ['High', 'Medium', 'Low']
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _priority = val!),
                  decoration: const InputDecoration(labelText: "Priority"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _repeat,
                  items:
                      ['None', 'Daily', 'Weekly', 'Monthly']
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _repeat = val!),
                  decoration: const InputDecoration(labelText: "Repeat"),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _category,
                  items:
                      ['General', 'Work', 'Personal', 'Study']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      "Checklist",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final text = _subtaskController.text.trim();
                        if (text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Checklist item cannot be empty",
                          );
                          return;
                        }
                        setState(() {
                          _checklist.add(text);
                          _subtaskController.clear();
                        });
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _subtaskController,
                  decoration: const InputDecoration(hintText: "Add a subtask"),
                ),
                const SizedBox(height: 10),
                Column(
                  children:
                      _checklist
                          .asMap()
                          .entries
                          .map(
                            (entry) => ListTile(
                              title: Text(entry.value),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _checklist.removeAt(entry.key);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: Icon(isEditing ? Icons.edit : Icons.save),
                    label: Text(isEditing ? 'Update Task' : 'Save Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
