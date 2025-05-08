import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:todo_list/screens/auth/login_screen.dart';
import 'package:todo_list/screens/home/home_screen.dart';
import 'package:todo_list/controllers/theme_controller.dart';
import 'package:todo_list/controllers/task_controller.dart'; // ✅ Import task controller

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Kigali'));

  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();

  // Initialize controllers globally
  Get.put(ThemeController());
  Get.put(TaskController()); // ✅ Register once globally

  final isLoggedIn = prefs.getString('current_user') != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToDo List',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
