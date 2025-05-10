import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/screens/home/home_screen.dart';
import 'package:todo_list/screens/auth/register_screen.dart';
import 'package:todo_list/models/user_model.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_list/screens/auth/reset_password_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('users') ?? [];

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    List<UserModel> users =
        usersJson
            .map((jsonStr) => UserModel.fromMap(json.decode(jsonStr)))
            .toList();

    final match = users.any(
      (user) => user.email == email && user.password == password,
    );

    if (match) {
      await prefs.setString('current_user', email);
      final name = users.firstWhere((user) => user.email == email).name;
      await prefs.setString('current_user_name', name);

      Fluttertoast.showToast(
        msg: "Welcome back, $name!",
        gravity: ToastGravity.BOTTOM,
      );
      Get.offAll(const HomeScreen());
    } else {
      Fluttertoast.showToast(
        msg: "Invalid email or password",
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator:
                          (val) =>
                              val == null || !val.contains('@')
                                  ? 'Enter valid email'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator:
                          (val) =>
                              val == null || val.length < 6
                                  ? 'Minimum 6 characters'
                                  : null,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text("Login"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.to(() => const RegisterScreen()),
                      child: const Text("Don't have an account? Register"),
                    ),

                    TextButton(
                      onPressed:
                          () => Get.to(() => const ResetPasswordScreen()),
                      child: const Text("Forgot Password?"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
