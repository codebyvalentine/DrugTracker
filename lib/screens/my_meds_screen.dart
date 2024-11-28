import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  Future<void> _fetchMedications() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot medicationsSnapshot = await _firestore
          .collection('medications')
          .doc(user.uid)
          .collection('userMedications')
          .get();

      final List<Map<String, dynamic>> medications = [];

      for (var doc in medicationsSnapshot.docs) {
        final medicationData = doc.data() as Map<String, dynamic>?;

        if (medicationData == null) continue;

        final String drugName = medicationData['drugName'] ?? 'Unknown';
        final String pills = medicationData['pills'] ?? 'Unknown';
        final String form = medicationData['form'] ?? '';
        final String dosage = medicationData['dosage'] ?? '';
        final String note = medicationData['note'] ?? '';
        final DateTime startDate = DateTime.parse(medicationData['startDate']);
        final DateTime endDate = DateTime.parse(medicationData['endDate']);

        // Fetch reminders
        final QuerySnapshot remindersSnapshot =
        await doc.reference.collection('reminders').get();

        final List<Map<String, dynamic>> reminders = remindersSnapshot.docs
            .map((reminderDoc) {
          final reminderData = reminderDoc.data() as Map<String, dynamic>?;
          if (reminderData == null) return null;

          return {
            'time': reminderData['time'],
            'frequency': reminderData['frequency'] ?? 'Daily',
            'startDate': reminderData['startDate'],
            'endDate': reminderData['endDate'],
          };
        })
            .where((reminder) => reminder != null)
            .toList()
            .cast<Map<String, dynamic>>();

        medications.add({
          'id': doc.id,
          'drugName': drugName,
          'pills': pills,
          'form': form,
          'dosage': dosage,
          'note': note,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'reminders': reminders,
        });
      }

      setState(() {
        _medications = medications;
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
        print("Error deleting medication: $e");
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

  void _showDetailsPopup(Map<String, dynamic> med) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            med['drugName'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                _buildDetailRow('Quantity', med['pills']),
                _buildDetailRow('Form', med['form']),
                if (med['dosage'].isNotEmpty) _buildDetailRow('Dosage', med['dosage']),
                _buildDetailRow('Start Date', med['startDate']),
                _buildDetailRow('End Date', med['endDate']),
                if (med['note'].isNotEmpty) _buildDetailRow('Note', med['note']),
                const SizedBox(height: 16),
                const Text(
                  'Reminders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...med['reminders'].map<Widget>((reminder) {
                  return Text(
                    'Time: ${reminder['time']}, Frequency: ${reminder['frequency']}',
                    style: TextStyle(color: Colors.grey[700]),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close", style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
          ? const Center(child: Text('You have no medications added'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _medications.map((med) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              color: AppTheme.lightCardGreen,
              child: ListTile(
                title: Text(
                  med['drugName'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Quantity: ${med['pills']}\nForm: ${med['form']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () {
                        _showDetailsPopup(med);
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
      ),
    );
  }
}
