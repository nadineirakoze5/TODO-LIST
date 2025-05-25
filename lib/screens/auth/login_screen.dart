import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:oktoast/oktoast.dart';

import 'register_screen.dart';
import 'reset_password_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', email);
      await prefs.setString(
        'current_user_name',
        userCredential.user?.displayName ?? "ToDo User",
      );

      showToast(
        "👋 Welcome back, ${userCredential.user?.displayName ?? email}",
        position: ToastPosition.bottom,
      );

      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      String message = "❌ Login failed";
      if (e.code == 'user-not-found') {
        message = "⚠️ No user found with this email";
      } else if (e.code == 'wrong-password') {
        message = "⚠️ Incorrect password. Try again.";
      } else if (e.code == 'invalid-email') {
        message = "⚠️ Invalid email format";
      }

      showToast(message, position: ToastPosition.bottom);
    } catch (e) {
      showToast(
        "❌ Unexpected error: ${e.toString()}",
        position: ToastPosition.bottom,
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
