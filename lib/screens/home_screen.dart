import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _fetchUserData() async {
    final User? user = _auth.currentUser;
    return "Hello, ${user?.displayName ?? 'User'}";
  }

  final List<Map<String, String>> upcomingMeds = const [
    {'name': 'Paracetamol', 'time': '8:00 AM'},
    {'name': 'Ibuprofen', 'time': '12:00 PM'},
    {'name': 'Aspirin', 'time': '5:00 PM'},
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else {
          final greeting = snapshot.data ?? "Hello, User";
          return Column(
            children: [
              // Greeting Message
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Upcoming Medications Section
              const Padding(
                padding: EdgeInsets.all(16.0),
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
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppTheme.lightCardGreen, // Custom green card background
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          medication['name']!,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Time: ${medication['time']}',
                          style: const TextStyle(fontSize: 14),
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
      },
    );
  }
}