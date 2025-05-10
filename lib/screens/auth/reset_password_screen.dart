import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/models/user_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _resetPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final email = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (email.isEmpty || newPassword.isEmpty) {
      Fluttertoast.showToast(msg: 'Fill both fields');
      return;
    }

    final usersJson = prefs.getStringList('users') ?? [];
    List<UserModel> users = usersJson
        .map((e) => UserModel.fromMap(json.decode(e)))
        .toList();

    final userIndex = users.indexWhere((u) => u.email == email);
    if (userIndex == -1) {
      Fluttertoast.showToast(msg: 'Email not found');
      return;
    }

    users[userIndex] = UserModel(
      name: users[userIndex].name,
      email: email,
      password: newPassword,
    );

    final updatedJson =
        users.map((u) => json.encode(u.toMap())).toList();
    await prefs.setStringList('users', updatedJson);

    Fluttertoast.showToast(msg: '✅ Password updated!');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Reset Password'),
            )
          ],
        ),
      ),
    );
  }
}
