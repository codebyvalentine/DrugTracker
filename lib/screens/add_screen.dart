import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'my_meds_screen.dart';

// AddScreen starts here
class AddScreen extends StatefulWidget {
  final Map<String, dynamic>? medication;

  const AddScreen({Key? key, this.medication}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController drugNameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedForm;
  String _quantityLabel = 'How many pills?';

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      drugNameController.text = widget.medication!['name'] ?? '';
      dosageController.text = widget.medication!['dosage'] ?? '';
      quantityController.text = widget.medication!['quantity'] ?? '';
      _selectedForm = widget.medication!['form'];
      _updateQuantityLabel();
    }
  }

  @override
  void dispose() {
    drugNameController.dispose();
    dosageController.dispose();
    quantityController.dispose();
    endDateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _updateQuantityLabel() {
    setState(() {
      _quantityLabel = 'How many ${_selectedForm?.toLowerCase() ?? 'pills'}?';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        endDateController.text = "${picked.toLocal()}".split(' ')[0];
      });
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: drugNameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: _selectedForm,
                decoration: const InputDecoration(
                  labelText: 'Medication Form',
                ),
                items: [
                  'Tablet',
                  'Capsule',
                  'Liquid',
                  'Injection',
                  'Inhaler',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedForm = newValue;
                    _updateQuantityLabel();
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select the medication form';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage (optional)',
                  hintText: 'e.g. 10 mg',
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _quantityLabel,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40.0),
              Text(
                'Advanced Settings',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: endDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'End Date (optional)',
                  hintText: 'e.g. 2024-12-31',
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Additional Note (optional)',
                  hintText: 'e.g. Take with food',
                ),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleScreen(
                          drugName: drugNameController.text,
                          dosage: dosageController.text,
                          pills: quantityController.text,
                          form: _selectedForm!,
                          endDate: endDateController.text,
                          note: noteController.text,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ScheduleScreen starts here
class ScheduleScreen extends StatefulWidget {
  final String drugName;
  final String dosage;
  final String pills;
  final String form;
  final String endDate;
  final String note;

  const ScheduleScreen({
    Key? key,
    required this.drugName,
    required this.dosage,
    required this.pills,
    required this.form,
    required this.endDate,
    required this.note,
  }) : super(key: key);

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final TextEditingController timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedFrequency;
  final List<Map<String, String>> _schedules = [];
  int? _editingIndex;
  static const int maxSchedules = 4;

  @override
  void dispose() {
    timeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  void _showAddPopup(BuildContext context, {int? index}) {
    if (index != null) {
      timeController.text = _schedules[index]['time']!;
      _selectedFrequency = _schedules[index]['frequency'];
      _editingIndex = index;
    } else {
      timeController.clear();
      _selectedFrequency = null;
      _editingIndex = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(index == null ? 'Add Schedule' : 'Edit Schedule'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    hintText: 'e.g. 8:00 AM',
                  ),
                  onTap: () => _selectTime(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: _selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
                  ),
                  items: [
                    'Daily',
                    'Every 2 days',
                    'Every 3 days',
                    'Every 4 days',
                    'Every 5 days',
                    'Every 6 days',
                    'Every 7 days',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedFrequency = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the frequency';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    if (_editingIndex != null) {
                      _schedules[_editingIndex!] = {
                        'time': timeController.text,
                        'frequency': _selectedFrequency!,
                      };
                    } else {
                      _schedules.add({
                        'time': timeController.text,
                        'frequency': _selectedFrequency!,
                      });
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(index == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Medication'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_schedules.isEmpty)
                Column(
                  children: [
                    Center(
                      child: Text(
                        'No schedules. Click the add button to add schedules',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _schedules.length + 1,
                itemBuilder: (context, index) {
                  if (index == _schedules.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('More'),
                          ElevatedButton(
                            onPressed: _schedules.length < maxSchedules
                                ? () => _showAddPopup(context)
                                : null,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    );
                  }
                  final schedule = _schedules[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        'Time: ${schedule['time']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Text(
                        'Frequency: ${schedule['frequency']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.0,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddPopup(context, index: index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteSchedule(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Previous',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_schedules.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please add at least one schedule.'),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConfirmScreen(
                                drugName: widget.drugName,
                                dosage: widget.dosage,
                                pills: widget.pills,
                                form: widget.form,
                                schedules: _schedules,
                                endDate: widget.endDate,
                                note: widget.note,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ConfirmScreen starts here


class ConfirmScreen extends StatefulWidget {
  final String drugName;
  final String dosage;
  final String pills;
  final String form;
  final List<Map<String, String>> schedules;
  final String? endDate;
  final String? note;

  const ConfirmScreen({
    Key? key,
    required this.drugName,
    required this.dosage,
    required this.pills,
    required this.form,
    required this.schedules,
    this.endDate,
    this.note,
  }) : super(key: key);

  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  Future<void> _saveToDatabase(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in
      return;
    }

    final CollectionReference medications = FirebaseFirestore.instance
        .collection('medications')
        .doc(user.uid)
        .collection('userMedications');

    final DateTime now = DateTime.now();
    final DateTime endDate = widget.endDate != null && widget.endDate!.isNotEmpty
        ? DateTime.parse(widget.endDate!)
        : now.add(Duration(days: 365 * 2));

    DocumentReference medicationRef = await medications.add({
      'drugName': widget.drugName,
      'dosage': widget.dosage,
      'pills': widget.pills,
      'form': widget.form,
      'endDate': Timestamp.fromDate(endDate),
      'note': widget.note,
      'dateAdded': Timestamp.fromDate(now),
    });

    for (var schedule in widget.schedules) {
      final timeParts = schedule['time']!.split(' ');
      final period = timeParts[1];
      final timeOfDay = TimeOfDay(
        hour: int.parse(timeParts[0].split(':')[0]) + (period == 'PM' ? 12 : 0),
        minute: int.parse(timeParts[0].split(':')[1]),
      );
      final DateTime scheduleTime = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );

      await medicationRef.collection('schedules').add({
        'time': Timestamp.fromDate(scheduleTime),
        'frequency': schedule['frequency'],
      });
    }

    // Redirect to MyMedsScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyMedsScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drug Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.drugName,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (widget.dosage.isNotEmpty) ...[
                      const SizedBox(height: 15.0),
                      Text(
                        'Dosage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        widget.dosage,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    const SizedBox(height: 15.0),
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.pills,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Text(
                      'Form',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.form,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Text(
                      'Schedules',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    ...widget.schedules.map((schedule) => Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Time: ${schedule['time']}, Frequency: ${schedule['frequency']}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    )),
                    if (widget.endDate != null && widget.endDate!.isNotEmpty) ...[
                      const SizedBox(height: 15.0),
                      Text(
                        'End Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        widget.endDate!,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    if (widget.note != null && widget.note!.isNotEmpty) ...[
                      const SizedBox(height: 15.0),
                      Text(
                        'Additional Note',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(
                        widget.note!,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Previous',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveToDatabase(context),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}