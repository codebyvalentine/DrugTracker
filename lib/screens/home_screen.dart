import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

//HomeScreenContent starts here

class HomeScreenContent extends StatelessWidget {
  final String greeting;
  final String firstName;
  final DateTime selectedDate;
  final VoidCallback onPreviousDate;
  final VoidCallback onNextDate;
  final List<Map<String, dynamic>> medications;

  HomeScreenContent({
    required this.greeting,
    required this.firstName,
    required this.selectedDate,
    required this.onPreviousDate,
    required this.onNextDate,
    required this.medications,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    final yesterday = now.subtract(Duration(days: 1));

    String dateString;
    if (selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day) {
      dateString = 'Today';
    } else if (selectedDate.year == tomorrow.year &&
        selectedDate.month == tomorrow.month &&
        selectedDate.day == tomorrow.day) {
      dateString = 'Tomorrow';
    } else if (selectedDate.year == yesterday.year &&
        selectedDate.month == yesterday.month &&
        selectedDate.day == yesterday.day) {
      dateString = 'Yesterday';
    } else {
      dateString = dateFormat.format(selectedDate);
    }

    // Split medications by individual times
    final Map<String, List<Map<String, dynamic>>> groupedMedications = {};
    for (var med in medications) {
      final times = med['time'].split('\nTime: ');
      for (var time in times) {
        if (!groupedMedications.containsKey(time)) {
          groupedMedications[time] = [];
        }
        groupedMedications[time]!.add({
          'name': med['name'],
          'quantity': med['quantity'],
        });
      }
    }

    // Sort the times
    final sortedTimes = groupedMedications.keys.toList()
      ..sort((a, b) => timeFormat.parse(a).compareTo(timeFormat.parse(b)));

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                '$greeting, $firstName',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: onPreviousDate,
                ),
                Text(
                  dateString,
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: onNextDate,
                ),
              ],
            ),
            if (dateString == 'Today') ...sortedTimes.map((time) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                    child: Text(
                      time,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  ...groupedMedications[time]!.map((med) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                            med['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Quantity: ${med['quantity']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 24), // More spacing after each time section
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  String _greeting = '';
  String _firstName = '';
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _setGreeting();
    _checkLoginStatus();
    _fetchUserProfile();
    _fetchMedications();
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
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      if (result != true) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _firstName = userDoc['firstName'] ?? 'User';
      });
    }
  }

  Future<void> _fetchMedications() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      int retryCount = 0;
      const int maxRetries = 3;
      while (retryCount < maxRetries) {
        try {
          final QuerySnapshot medicationsSnapshot = await FirebaseFirestore.instance
              .collection('medications')
              .doc(user.uid)
              .collection('userMedications')
              .get();
          final List<Map<String, dynamic>> medications = [];

          for (var doc in medicationsSnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final schedulesSnapshot = await doc.reference.collection('schedules').get();
            final List<String> times = schedulesSnapshot.docs.map((scheduleDoc) {
              final scheduleData = scheduleDoc.data() as Map<String, dynamic>;
              final Timestamp timeStamp = scheduleData['time'];
              final DateTime dateTime = timeStamp.toDate();
              final String formattedTime = DateFormat('hh:mm a').format(dateTime);
              return '$formattedTime (${scheduleData['frequency'] ?? 'Unknown'})';
            }).toList().cast<String>();

            final Timestamp endDateTimestamp = data['endDate'];
            final DateTime endDate = endDateTimestamp.toDate();
            final String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

            medications.add({
              'id': doc.id,
              'name': data['drugName'] ?? 'Unknown',
              'quantity': data['pills'] ?? 'Unknown',
              'time': times.join('\nTime: '),
              'dosage': data['dosage'] ?? '',
              'endDate': formattedEndDate,
              'note': data['note'] ?? '',
            });
          }

          setState(() {
            _medications = medications;
            _isLoading = false;
          });
          break; // Exit the loop if successful
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            print("Error fetching medications: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to load medications: $e")),
            );
          } else {
            await Future.delayed(Duration(seconds: 2)); // Wait before retrying
          }
        }
      }
    }
  }

  void _previousDate() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
      _fetchMedications();
    });
  }

  void _nextDate() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 1));
      _fetchMedications();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreenContent(
          greeting: _greeting,
          firstName: _firstName,
          selectedDate: _selectedDate,
          onPreviousDate: _previousDate,
          onNextDate: _nextDate,
          medications: _medications,
        );
      case 1:
        return AddScreen();
      case 2:
        return MyMedsScreen();
      case 3:
        return ZiraAIScreen();
      default:
        return HomeScreenContent(
          greeting: _greeting,
          firstName: _firstName,
          selectedDate: _selectedDate,
          onPreviousDate: _previousDate,
          onNextDate: _nextDate,
          medications: _medications,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        showBackButton: _selectedIndex != 0,
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTabChanged: _onTabChanged,
      ),
    );
  }
}