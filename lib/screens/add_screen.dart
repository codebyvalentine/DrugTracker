//The add logic is not complete yet. Needs a way to simplify it and avoid two button
//on one screen.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'my_meds_screen.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';
import '../utils/medication_validator.dart';

class AddScreen extends StatefulWidget {
  final Map<String, dynamic>? medication;

  const AddScreen({Key? key, this.medication}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController drugNameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController pillsController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController totalPillsController = TextEditingController();
  final TextEditingController frequencyTimeController = TextEditingController();
  String? frequencyInterval;
  String? medicationForm;
  bool showAdvancedSettings = false;
  bool showAddScheduleFields = false;
  List<Map<String, String>> schedules = [];
  int? editingIndex;
  String pillsLabel = 'How many pills?';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      drugNameController.text = widget.medication!['name'] ?? '';
      dosageController.text = widget.medication!['dosage'] ?? '';
      pillsController.text = widget.medication!['pills'] ?? '';
      frequencyInterval = widget.medication!['frequencyInterval'];
      endDateController.text = widget.medication!['endDate'] ?? '';
      notesController.text = widget.medication!['notes'] ?? '';
      totalPillsController.text = widget.medication!['totalPills'] ?? '';
      frequencyTimeController.text = widget.medication!['frequencyTime'] ?? '';
    }
  }

  @override
  void dispose() {
    drugNameController.dispose();
    dosageController.dispose();
    pillsController.dispose();
    endDateController.dispose();
    notesController.dispose();
    totalPillsController.dispose();
    frequencyTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectFrequencyTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        frequencyTimeController.text = picked.format(context);
      });
    }
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
          'pills': pillsController.text,
          'frequencyTime': frequencyTimeController.text,
          'frequencyInterval': frequencyInterval,
          'endDate': endDateController.text.isEmpty ? 'Indefinite' : endDateController.text,
          'notes': notesController.text,
          'totalPills': totalPillsController.text,
          'medicationForm': medicationForm,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Medication saved successfully")),
        );

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(initialIndex: 2), // Set initialIndex to 2 for MyMedsScreen
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

  void _addSchedule() {
  if (_formKey.currentState!.validate()) {
    setState(() {
      if (editingIndex != null) {
        schedules[editingIndex!] = {
          'pills': pillsController.text,
          'interval': frequencyInterval ?? '',
          'time': frequencyTimeController.text,
          'form': medicationForm ?? 'Pill',
        };
        editingIndex = null;
      } else {
        schedules.add({
          'pills': pillsController.text,
          'interval': frequencyInterval ?? '',
          'time': frequencyTimeController.text,
          'form': medicationForm ?? 'Pill',
        });
      }
      frequencyInterval = null;
      frequencyTimeController.clear();
      showAddScheduleFields = false;
    });
  }
}


  void _editSchedule(int index) {
    setState(() {
      editingIndex = index;
      pillsController.text = schedules[index]['pills']!;
      frequencyInterval = schedules[index]['interval'];
      frequencyTimeController.text = schedules[index]['time']!;
      medicationForm = schedules[index]['form'];
      showAddScheduleFields = true;
    });
  }

  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  String _getPluralForm(String form, String count) {
    int quantity = int.tryParse(count) ?? 1;
    return quantity > 1 ? '${form}s' : form;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: drugNameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                ),
                validator: MedicationValidator.validateMedicationName,
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: medicationForm,
                decoration: const InputDecoration(
                  labelText: 'Medication Form',
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    medicationForm = newValue;
                    switch (newValue) {
                      case 'Injection':
                        pillsLabel = 'How many injections?';
                        break;
                      case 'Solution':
                        pillsLabel = 'How many solutions?';
                        break;
                      case 'Drops':
                        pillsLabel = 'How many drops?';
                        break;
                      case 'Inhaler':
                        pillsLabel = 'How many inhalers?';
                        break;
                      case 'Powder':
                        pillsLabel = 'How many powders?';
                        break;
                      case 'Other':
                        pillsLabel = 'How many others?';
                        break;
                      default:
                        pillsLabel = 'How many pills?';
                    }
                  });
                },
                validator: MedicationValidator.validateMedicationForm,
                items: ['Pill', 'Injection', 'Solution', 'Drops', 'Inhaler', 'Powder', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10.0),
            // Move the "How many pills?" field below the dosage field
TextFormField(
  controller: dosageController,
  decoration: const InputDecoration(
    labelText: 'Dosage (optional)',
    hintText: 'e.g. 10 mg',
  ),
),
const SizedBox(height: 10.0),
TextFormField(
  controller: pillsController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: pillsLabel,
  ),
  validator: MedicationValidator.validatePills,
),
const SizedBox(height: 30.0),
const Text(
  "Enter Medication Schedule",
  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
),
const SizedBox(height: 10.0),
...schedules.asMap().entries.map((entry) {
  int index = entry.key;
  Map<String, String> schedule = entry.value;
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 5.0),
    child: ListTile(
      title: Text('${schedule['pills']} ${_getPluralForm(schedule['form']!, schedule['pills']!)}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How often: ${schedule['interval']}'),
          Text('When: ${schedule['time']}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSchedule(index),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSchedule(index),
          ),
        ],
      ),
    ),
  );
}).toList(),
const SizedBox(height: 10.0),
TextButton(
  onPressed: () {
    setState(() {
      showAddScheduleFields = !showAddScheduleFields;
    });
  },
  child: const Text('Click here to add schedule'),
),
if (showAddScheduleFields) ...[
  Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: frequencyInterval,
          decoration: const InputDecoration(
            labelText: 'How often',
          ),
          onChanged: (String? newValue) {
            setState(() {
              frequencyInterval = newValue;
            });
          },
          validator: MedicationValidator.validateFrequencyInterval,
          items: ['Daily', 'Every 2 days', 'Every 3 days']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      const SizedBox(width: 10.0),
      Expanded(
        child: TextFormField(
          controller: frequencyTimeController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'When',
            hintText: 'HH:MM AM/PM',
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () => _selectFrequencyTime(context),
            ),
          ),
          onTap: () => _selectFrequencyTime(context),
          validator: MedicationValidator.validateFrequencyTime,
        ),
      ),
    ],
  ),
  const SizedBox(height: 20.0),
  ElevatedButton(
    onPressed: _addSchedule,
    child: const Text('Add Schedule'),
  ),
],
const SizedBox(height: 10.0),
TextButton(
  onPressed: () {
    setState(() {
      showAdvancedSettings = !showAdvancedSettings;
    });
  },
  child: const Text('Advanced settings'),
),
if (showAdvancedSettings) ...[
  const SizedBox(height: 10.0),
  TextField(
    controller: totalPillsController,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
      labelText: 'Total No. of Pills',
    ),
  ),
  const SizedBox(height: 10.0),
  TextField(
    controller: endDateController,
    readOnly: true,
    decoration: InputDecoration(
      labelText: 'End Date (YYYY-MM-DD)',
      hintText: 'YYYY-MM-DD',
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () => _selectEndDate(context),
      ),
    ),
    keyboardType: TextInputType.datetime,
    onTap: () => _selectEndDate(context),
  ),
  const SizedBox(height: 10.0),
  TextField(
    controller: notesController,
    decoration: const InputDecoration(
      labelText: 'Additional Notes',
    ),
  ),
],
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
      ),
    );
  }
}