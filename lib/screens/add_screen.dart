//this is latest
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';

class AddScreen extends StatefulWidget {
  final Map<String, dynamic>? medication;

  const AddScreen({super.key, this.medication});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController drugNameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController pillsController = TextEditingController();
  final TextEditingController frequencyAmountController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String? frequency;
  String? frequencyUnit;
  String? durationUnit;
  bool isCustomFrequency = false;
  bool isIndefinite = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      drugNameController.text = widget.medication!['name'] ?? '';
      dosageController.text = widget.medication!['dosage'] ?? '';
      pillsController.text = widget.medication!['pills'] ?? '';
      frequencyAmountController.text = widget.medication!['frequencyAmount'] ?? '';
      durationController.text = widget.medication!['duration'] ?? '';
      notesController.text = widget.medication!['notes'] ?? '';
      frequency = widget.medication!['schedule'];
      frequencyUnit = widget.medication!['frequencyUnit'];
      durationUnit = widget.medication!['durationUnit'];
      isCustomFrequency = widget.medication!['isCustomFrequency'] ?? false;
      isIndefinite = widget.medication!['isIndefinite'] ?? false;
    }
  }

  @override
  void dispose() {
    drugNameController.dispose();
    dosageController.dispose();
    pillsController.dispose();
    frequencyAmountController.dispose();
    durationController.dispose();
    notesController.dispose();
    super.dispose();
  }
  Future<void> _saveMedication() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (user != null) {
      try {
        await _firestore
            .collection('medications')
            .doc(user.uid)
            .collection('userMedications')
            .add({
          'drugName': drugNameController.text,
          'dosage': dosageController.text,
          'frequency': frequency,
          'pills': isCustomFrequency ? pillsController.text : null,
          'frequencyUnit': isCustomFrequency ? frequencyUnit : null,
          'frequencyAmount': isCustomFrequency ? frequencyAmountController.text : null,
          'duration': isIndefinite ? 'Indefinite' : durationController.text,
          'durationUnit': isIndefinite ? null : durationUnit,
          'notes': notesController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Medication saved successfully")),
        );

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainScreen(initialIndex: 2), // Set initialIndex to 2 for MyMedsScreen
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save medication: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: drugNameController,
              decoration: const InputDecoration(
                labelText: 'Drug Name',
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
              ),
            ),
            const SizedBox(height: 30.0),
            const Text(
              "Step 2: Schedule",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Column(
              children: [
                ListTile(
                  title: const Text("Once Daily"),
                  leading: Radio<String>(
                    value: 'Once Daily',
                    groupValue: frequency,
                    onChanged: (String? value) {
                      setState(() {
                        frequency = value;
                        isCustomFrequency = false;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  title: const Text("Twice Daily"),
                  leading: Radio<String>(
                    value: 'Twice Daily',
                    groupValue: frequency,
                    onChanged: (String? value) {
                      setState(() {
                        frequency = value;
                        isCustomFrequency = false;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  title: const Text("Every 8 Hours"),
                  leading: Radio<String>(
                    value: 'Every 8 Hours',
                    groupValue: frequency,
                    onChanged: (String? value) {
                      setState(() {
                        frequency = value;
                        isCustomFrequency = false;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  title: const Text("Custom Frequency"),
                  leading: Radio<String>(
                    value: 'Custom',
                    groupValue: frequency,
                    onChanged: (String? value) {
                      setState(() {
                        frequency = value;
                        isCustomFrequency = true;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            if (isCustomFrequency) ...[
              const SizedBox(height: 10.0),
              TextField(
                controller: pillsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'How many pills?',
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: frequencyAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter interval (e.g., 6)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: frequencyUnit,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          frequencyUnit = newValue;
                        });
                      },
                      items: ['Hours', 'Days', 'Weeks']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 30.0),
            const Text(
              "Step 3: Duration and Notes",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter duration',
                    ),
                    enabled: !isIndefinite,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: durationUnit,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: isIndefinite
                        ? null
                        : (String? newValue) {
                            setState(() {
                              durationUnit = newValue;
                            });
                          },
                    items: ['Days', 'Weeks', 'Months']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Checkbox(
                  value: isIndefinite,
                  onChanged: (bool? value) {
                    setState(() {
                      isIndefinite = value!;
                      if (isIndefinite) {
                        durationController.clear();
                        durationUnit = 'Days';
                      }
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                const Text('Indefinite'),
              ],
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: _saveMedication,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4,
              ),
              child: const Text("Save Medication"),
            ),
          ],
        ),
      ),
    );
  }
}