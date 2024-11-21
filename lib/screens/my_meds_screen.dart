import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'add_screen.dart';

class MyMedsScreen extends StatefulWidget {
  const MyMedsScreen({super.key});
  @override
  _MyMedsScreenState createState() => _MyMedsScreenState();
}

class _MyMedsScreenState extends State<MyMedsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedTimeFilter = 'Time';
  String _selectedStatusFilter = 'Status';

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot documentSnapshot = await _firestore
            .collection('medications')
            .doc(user.uid)
            .get();
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _medications = [
              {
                'name': data['drugName'] ?? 'Unknown',
                'dosage': data['dosage'] ?? 'Unknown',
                'schedule': data['frequency'] ?? 'Unknown',
                'time': data['time'] ?? 'Unknown',
                'status': data['status'] ?? 'Unknown',
              }
            ];
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load medications: $e")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final filteredMeds = _medications.where((med) {
      final matchesSearch = _searchQuery.isEmpty ||
          med['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTime = _selectedTimeFilter == 'Time' ||
          (_selectedTimeFilter == 'Morning' && med['time'].contains('AM')) ||
          (_selectedTimeFilter == 'Evening' && med['time'].contains('PM'));
      final matchesStatus = _selectedStatusFilter == 'Status' ||
          (_selectedStatusFilter == 'On Track' && med['status'] == 'on track') ||
          (_selectedStatusFilter == 'Missed' && med['status'] == 'missed');
      return matchesSearch && matchesTime && matchesStatus;
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (value) => setState(() {
                      _searchQuery = value;
                    }),
                    decoration: InputDecoration(
                      hintText: 'Search medications...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Medications',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _selectedTimeFilter,
                                items: ['Time', 'Morning', 'Evening']
                                    .map((filter) => DropdownMenuItem(
                                          value: filter,
                                          child: Text(filter),
                                        ))
                                    .toList(),
                                onChanged: (value) => setState(() {
                                  _selectedTimeFilter = value!;
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, size: 18),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _selectedStatusFilter,
                                items: ['Status', 'On Track', 'Missed']
                                    .map((filter) => DropdownMenuItem(
                                          value: filter,
                                          child: Text(filter),
                                        ))
                                    .toList(),
                                onChanged: (value) => setState(() {
                                  _selectedStatusFilter = value!;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: filteredMeds.map((med) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        color: AppTheme.lightCardGreen,
                        child: ListTile(
                          title: Text(med['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${med['dosage']} • ${med['schedule']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Edit logic
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _medications.remove(med);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        foregroundColor: AppTheme.whiteColor,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}