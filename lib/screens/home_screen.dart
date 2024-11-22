import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'add_screen.dart';
import 'zira_ai.dart';
import 'my_meds_screen.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/top_bar.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Screen Content'),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  String _greeting = '';
  final List<Map<String, String>> _upcomingMeds = [
    {'name': 'Paracetamol', 'time': '8:00 AM'},
    {'name': 'Ibuprofen', 'time': '12:00 PM'},
    {'name': 'Aspirin', 'time': '5:00 PM'},
  ];

  final List<Widget> _screens = [
    HomeScreenContent(),
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
    _setGreeting();
    _checkLoginStatus();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      _greeting = 'Good Afternoon';
    } else if (hour >= 18 && hour < 21) {
      _greeting = 'Good Evening';
    } else {
      _greeting = 'Good Night';
    }
  }

  Future<void> _checkLoginStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in, redirect to login screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      if (result != true) {
        // If login was not successful, navigate back
        Navigator.pop(context);
      }
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