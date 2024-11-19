import 'package:flutter/material.dart';
import 'add_screen.dart';
import 'zira_ai.dart';
import 'my_meds_screen.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/top_bar.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _greeting = '';
  List<Map<String, String>> _upcomingMeds = [
    {'name': 'Paracetamol', 'time': '8:00 AM'},
    {'name': 'Ibuprofen', 'time': '12:00 PM'},
    {'name': 'Aspirin', 'time': '5:00 PM'},
  ];

  final List<Widget> _screens = [
    HomeScreenContent(), // Home Screen content
    AddScreen(),
    MyMedsScreen(),
    ZiraAIScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setGreeting();
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

// HomeScreenContent Widget for the greeting and upcoming medications
class HomeScreenContent extends StatelessWidget {
  final String greeting;
  final List<Map<String, String>> upcomingMeds;

  HomeScreenContent({
    Key? key,
  })  : greeting = "Good Morning, Jack!", // Set the greeting message here
        upcomingMeds = [
          {'name': 'Paracetamol', 'time': '8:00 AM'},
          {'name': 'Ibuprofen', 'time': '12:00 PM'},
          {'name': 'Aspirin', 'time': '5:00 PM'},
        ], // Placeholder for upcoming medications
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Greeting Message
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            greeting,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        // Upcoming Medications Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Medications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Upcoming Medications List
        Expanded(
          child: ListView.builder(
            itemCount: upcomingMeds.length,
            itemBuilder: (context, index) {
              final medication = upcomingMeds[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppTheme.lightCardGreen,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    medication['name']!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Time: ${medication['time']}',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.alarm,
                    color: Theme.of(context).primaryColor,
                  ),
                  onTap: () {
                    // Placeholder for navigation to medication detail page
                    // You can navigate to a specific page here
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
