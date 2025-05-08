import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/screens/auth/login_screen.dart';
import 'package:todo_list/controllers/theme_controller.dart'; // ✅ Import controller

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  String? name;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('current_user');
      name = prefs.getString('current_user_name');
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('current_user_name');
    Get.offAll(const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 20),
            Text(
              "Name: ${name ?? 'Loading...'}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Email: ${email ?? 'Loading...'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => themeController.toggleTheme(),
              icon: const Icon(Icons.brightness_6),
              label: const Text("Toggle Theme"),
            ),
          ],
        ),
      ),
    );
  }
}
