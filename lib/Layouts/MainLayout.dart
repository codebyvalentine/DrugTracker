import 'package:flutter/material.dart';
import 'package:main/screens/add_screen.dart';
import 'package:main/screens/main_screen.dart';
import 'package:main/screens/my_meds_screen.dart';
import 'package:main/screens/notification_screen.dart';
import 'package:main/screens/profile_screen.dart';
import 'package:main/screens/zira_ai.dart';
import 'package:main/widgets/navigation_bar.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/home',
    '/add',
    '/myMeds',
    '/ziraAI',
    '/profile',
    '/notifications'
  ];

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushNamed(context, _routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        initialRoute: '/home',
        onGenerateRoute: (settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/home':
              builder = (BuildContext _) => const MainScreen();
              break;
            case '/add':
              builder = (BuildContext _) => const AddScreen();
              break;
            case '/myMeds':
              builder = (BuildContext _) => const MyMedsScreen();
              break;
            case '/ziraAI':
              builder = (BuildContext _) => const ZiraAIScreen();
              break;
            case '/profile':
              builder = (BuildContext _) => const ProfileScreen();
              break;
            case '/notifications':
              builder = (BuildContext _) => const NotificationScreen();
              break;
            default:
              throw Exception('Invalid route: ${settings.name}');
          }
          return MaterialPageRoute(builder: builder, settings: settings);
        },
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}