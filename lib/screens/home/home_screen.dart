import 'package:flutter/material.dart';
import 'package:todo_list/screens/home/filter_screen.dart';
import 'package:todo_list/screens/home/calendar_screen.dart';
import 'package:todo_list/screens/home/task_stats_screen.dart';
import 'package:todo_list/screens/profile/profile_screen.dart'; // ✅ CORRECT path
import 'package:todo_list/screens/home/all_tasks_screen.dart';        // ✅ fixed
      

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AllTasksScreen(),
    CalendarScreen(),
    FilterScreen(),
    TaskStatsScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = [
    "All Tasks",
    "Calendar",
    "Filter",
    "Stats",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Filter',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
