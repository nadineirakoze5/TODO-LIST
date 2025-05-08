import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  @override
  void onInit() {
    loadTheme();
    super.onInit();
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('is_dark_mode') ?? false;
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = !isDarkMode.value;
    await prefs.setBool('is_dark_mode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
