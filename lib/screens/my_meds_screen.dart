import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'add_screen.dart';

class MyMedsScreen extends StatefulWidget {
  const MyMedsScreen({super.key});

  @override
  _MyMedsScreenState createState() => _MyMedsScreenState();
}

class _MyMedsScreenState extends State<MyMedsScreen> {
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Paracetamol',
      'dosage': '500mg',
      'schedule': 'Once Daily at 8:00 AM',
      'status': 'on track',
      'time': '8:00 AM',
    },
    {
      'name': 'Ibuprofen',
      'dosage': '200mg',
      'schedule': 'Every 8 Hours',
      'status': 'missed',
      'time': '12:00 PM',
    },
    {
      'name': 'Aspirin',
      'dosage': '100mg',
      'schedule': 'Twice Daily at 7:00 AM, 7:00 PM',
      'status': 'on track',
      'time': '7:00 PM',
    },
  ];

  // Search query
  String _searchQuery = '';

  // Filter by time/status
  String _selectedTimeFilter = 'Time'; // Default placeholder
  String _selectedStatusFilter = 'Status'; // Default placeholder

  @override
  Widget build(BuildContext context) {
    // Filter and search logic
    final filteredMeds = _medications.where((med) {
      final matchesSearch = _searchQuery.isEmpty ||
          med['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTime = _selectedTimeFilter == 'Time' ||
          (_selectedTimeFilter == 'Morning' && med['time'].contains('AM')) ||
          (_selectedTimeFilter == 'Evening' && med['time'].contains('PM'));
      final matchesStatus = _selectedStatusFilter == 'Status' ||
          (_selectedStatusFilter == 'On Track' &&
              med['status'] == 'on track') ||
          (_selectedStatusFilter == 'Missed' && med['status'] == 'missed');
      return matchesSearch && matchesTime && matchesStatus;
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: (value) => setState(() {
                _searchQuery = value;
              }),
              decoration: InputDecoration(
                hintText: 'Search medications...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),

            // Row for "All Medications" and Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // "All Medications" Text
                const Text(
                  'All Medications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Filters (Time and Status)
                Row(
                  children: [
                    // Time Filter Dropdown with Icon
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
                    // Status Filter Dropdown
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

            // Medication List Section
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
                            // Delete logic
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

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Screen
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
