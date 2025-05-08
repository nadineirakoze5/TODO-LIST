import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/screens/auth/login_screen.dart';
import 'package:todo_list/models/user_model.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('users') ?? [];

    List<UserModel> users =
        usersJson
            .map((jsonStr) => UserModel.fromMap(json.decode(jsonStr)))
            .toList();

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    final exists = users.any((user) => user.email == email);

    if (exists) {
      Fluttertoast.showToast(
        msg: "Email already registered",
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final newUser = UserModel(name: name, email: email, password: password);
    users.add(newUser);
    final updatedJson = users.map((u) => json.encode(u.toMap())).toList();

    await prefs.setStringList('users', updatedJson);
    await prefs.setString('current_user', email);
    await prefs.setString('current_user_name', name);

    Fluttertoast.showToast(
      msg: "Account created successfully!",
      gravity: ToastGravity.BOTTOM,
    );
    Get.offAll(const LoginScreen());
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
                      "Register",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Enter your name'
                                  : null,
                    ),
                    const SizedBox(height: 20),
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
                        onPressed: _register,
                        child: const Text("Register"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Already have an account? Login"),
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
