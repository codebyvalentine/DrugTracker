import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:main/screens/home_screen.dart';
import 'package:main/screens/login_screen.dart';
import 'package:main/screens/profile_screen.dart';
import 'add_screen.dart';
import 'zira_ai.dart';
import 'my_meds_screen.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/top_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AddScreen(),
    const MyMedsScreen(),
    const ZiraAIScreen(),
    const LoginScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() {
    if (_auth.currentUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        showBackButton: _selectedIndex != 0,
        onBack: () {
          setState(() {
            _selectedIndex = 0; // Navigate back to Home Screen
          });
        },
      ),
      body: _screens[_selectedIndex], // Display selected screen content
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}