import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Load .env file before running the app
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase successfully connected!");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

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
