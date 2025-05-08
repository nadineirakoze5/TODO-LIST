import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey[100],
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
