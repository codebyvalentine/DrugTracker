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
        final QuerySnapshot medicationsSnapshot = await _firestore
            .collection('medications')
            .doc(user.uid)
            .collection('userMedications')
            .get();
        final List<Map<String, dynamic>> medications = medicationsSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['drugName'] ?? 'Unknown',
            'dosage': data['dosage'] ?? 'Unknown',
            'schedule': data['frequency'] ?? 'Unknown',
            'time': data['time'] ?? 'Unknown',
            'status': data['status'] ?? 'Unknown',
          };
        }).toList();
        setState(() {
          _medications = medications;
          _isLoading = false;
        });
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

  void _deleteMedication(Map<String, dynamic> med) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('medications')
            .doc(user.uid)
            .collection('userMedications')
            .doc(med['id'])
            .delete();
        setState(() {
          _medications.remove(med);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Medication deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete medication: $e")),
        );
      }
    }
  }

  void _confirmDeleteMedication(Map<String, dynamic> med) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this medication?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMedication(med);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
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
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
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
                          decoration: InputDecoration(
                            labelText: 'Time',
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
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
                          decoration: InputDecoration(
                            labelText: 'Status',
                            prefixIcon: const Icon(Icons.check_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddScreen(medication: med),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDeleteMedication(med);
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