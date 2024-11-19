import 'package:flutter/material.dart';

// Helper to show a snackbar
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}

// Helper for formatted dates
String formatDate(DateTime date) {
  return "${date.day}-${date.month}-${date.year}";
}

// Helper for validating email input
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}
