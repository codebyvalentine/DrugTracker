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
    if (user != null) {
      try {
        final QuerySnapshot medicationsSnapshot = await _firestore
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
            final String formattedTime = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
            return '$formattedTime (${scheduleData['frequency'] ?? 'Unknown'})';
          }).toList().cast<String>();

          final Timestamp endDateTimestamp = data['endDate'];
          final DateTime endDate = endDateTimestamp.toDate();
          final String formattedEndDate = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

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
      } catch (e) {
        print("Error fetching medications: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load medications: $e")),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("User is not logged in");
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
    } else {
      print("User is not logged in");
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
            med['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                _buildDetailRow('Quantity', med['quantity']),
                _buildDetailRow('Time', med['time']),
                if (med['dosage'].isNotEmpty) _buildDetailRow('Dosage', med['dosage']),
                if (med['endDate'].isNotEmpty) _buildDetailRow('End Date', med['endDate']),
                if (med['note'].isNotEmpty) _buildDetailRow('Note', med['note']),
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
                  med['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Quantity: ${med['quantity']}\nTime: ${med['time']}',
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