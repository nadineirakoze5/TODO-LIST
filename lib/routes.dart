import 'package:get/get.dart';
import 'package:todo_list/screens/auth/login_screen.dart';
import 'package:todo_list/screens/home/home_screen.dart';
import 'package:todo_list/screens/task/add_edit_task_screen.dart';

final routes = [
  GetPage(name: '/login', page: () => const LoginScreen()),
  GetPage(name: '/home', page: () => const HomeScreen()),
  GetPage(name: '/add', page: () => const AddEditTaskScreen()),
];
