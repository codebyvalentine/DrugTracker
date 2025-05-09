import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Load .env file before running the app
  await dotenv.load(fileName: ".env");

  runApp(const PrescribrApp());
}

class PrescribrApp extends StatelessWidget {
  const PrescribrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Use the light theme
      home: const HomeScreen(),
    );
  }
}
