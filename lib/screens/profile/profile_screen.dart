import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/screens/auth/login_screen.dart';
import 'package:todo_list/controllers/theme_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? email;
  String? name;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('current_user');

    if (userEmail != null) {
      setState(() => email = userEmail);
      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userEmail)
                .get();

        if (snapshot.exists) {
          setState(() {
            name = snapshot.data()?['name'] ?? 'Unknown';
          });
        } else {
          setState(() {
            name = prefs.getString('current_user_name') ?? 'No name';
          });
        }
      } catch (e) {
        setState(() {
          name = prefs.getString('current_user_name') ?? 'No name';
        });
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAll(() => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Name: ${name ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Email: ${email ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
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
