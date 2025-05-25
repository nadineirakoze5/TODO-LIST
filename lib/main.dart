import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart'; // For toast messages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; //  Firebase

import 'package:todo_list/screens/auth/login_screen.dart';
import 'package:todo_list/screens/home/home_screen.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:todo_list/controllers/theme_controller.dart';
import 'package:todo_list/controllers/task_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize Firebase
  await Firebase.initializeApp();

  //  Initialize Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Kigali'));

  //  Initialize Notifications
  await NotificationService.initialize();

  //  SharedPreferences and GetX Controllers
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getString('current_user') != null;

  Get.put(ThemeController());
  Get.put(TaskController());

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return OKToast(
      //  Wrap your app to support showToast()
      child: Obx(
        () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ToDo List',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode:
              themeController.isDarkMode.value
                  ? ThemeMode.dark
                  : ThemeMode.light,
          home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      ),
    );
  }
}
