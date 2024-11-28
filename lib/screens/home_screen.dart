import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'add_screen.dart';
import 'zira_ai.dart';
import 'my_meds_screen.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
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
  final bool isLoading;

  HomeScreenContent({
    required this.greeting,
    required this.firstName,
    required this.selectedDate,
    required this.onPreviousDate,
    required this.onNextDate,
    required this.medications,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Greeting Text
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text(
                '$greeting, $firstName',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // Date Navigation
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: onPreviousDate,
                ),
                Text(
                  dateFormat.format(selectedDate),
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: onNextDate,
                ),
              ],
            ),

            // Loader
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: CircularProgressIndicator(),
              )

            // No Reminders Message
            else if (medications.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(
                  'No reminders for this day.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )

            // Display Reminders
            else
              ...medications.map((med) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        'Quantity: ${med['quantity']}\nForm: ${med['form']}\nTime: ${DateFormat('hh:mm a').format(med['time'])}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseMessaging _firebaseMessaging;
  late int _selectedIndex;
  String _greeting = '';
  String _firstName = '';
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
    _selectedIndex = widget.initialIndex;
    _setGreeting();
    _checkLoginStatus();
    _fetchUserProfile();
    _fetchMedications();
  }

  void _initializeFirebaseMessaging() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'No Title';
        final body = message.notification!.body ?? 'No Body';

        // Access NotificationProvider and add notification
        final notificationProvider = context.read<NotificationProvider>();
        notificationProvider.addNotification(title, body);
      }
    });

    String? token = await _firebaseMessaging.getToken();
    print("Firebase Messaging Token: $token");
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
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final medicationsSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .doc(user.uid)
          .collection('userMedications')
          .get();

      final List<Map<String, dynamic>> remindersForDay = [];
      final DateTime startOfDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      for (var medicationDoc in medicationsSnapshot.docs) {
        final medicationData = medicationDoc.data();
        if (medicationData == null) continue;

        final remindersSnapshot = await medicationDoc.reference
            .collection('reminders')
            .get();

        for (var reminderDoc in remindersSnapshot.docs) {
          final reminderData = reminderDoc.data();
          if (reminderData == null) continue;

          final DateTime reminderStartDate = DateTime.parse(reminderData['startDate']);
          final DateTime reminderEndDate = DateTime.parse(reminderData['endDate']);
          final String frequency = reminderData['frequency'];
          final String reminderTime = reminderData['time'];

          // Ensure reminder is within start and end date range
          if (_selectedDate.isBefore(reminderStartDate) ||
              _selectedDate.isAfter(reminderEndDate)) {
            continue;
          }

          // Frequency logic
          bool shouldAddReminder = false;
          if (frequency == 'Daily') {
            shouldAddReminder = true;
          } else if (frequency.startsWith('Every')) {
            final daysInterval = int.parse(frequency.split(' ')[1]); // e.g., "Every 3 days"
            final int daysSinceStart = _selectedDate.difference(reminderStartDate).inDays;

            // Add reminder only if the current day aligns with the interval
            if (daysSinceStart >= 0 && daysSinceStart % daysInterval == 0) {
              shouldAddReminder = true;
            }
          }

          if (shouldAddReminder) {
            final reminderDateTime = DateTime(
              startOfDay.year,
              startOfDay.month,
              startOfDay.day,
              _parseTime(reminderTime).hour,
              _parseTime(reminderTime).minute,
            );

            remindersForDay.add({
              'name': medicationData['drugName'],
              'quantity': medicationData['pills'],
              'form': medicationData['form'],
              'time': reminderDateTime,
            });
          }
        }
      }

      setState(() {
        _medications = remindersForDay;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching medications: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load medications: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

// Helper method to parse time strings (e.g., "4:12 PM")
  TimeOfDay _parseTime(String time) {
    final format = DateFormat.jm(); // "4:12 PM"
    final DateTime dateTime = format.parse(time);
    return TimeOfDay.fromDateTime(dateTime);
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
          isLoading: _isLoading,
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
          isLoading: _isLoading,
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