import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  // Step 1: Drug Details
  final TextEditingController drugNameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();

  // Step 2: Schedule
  String? frequency = 'Once Daily';
  bool isCustomFrequency = false; // To show/hide custom frequency fields
  final TextEditingController pillsController = TextEditingController();
  String? frequencyUnit = 'Hours';
  final TextEditingController frequencyAmountController =
      TextEditingController();

  // Step 3: Duration and Notes
  String? durationUnit = 'Days'; // Default unit for duration
  final TextEditingController durationController = TextEditingController();
  bool isIndefinite = false; // Checkbox to toggle indefinite duration
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: Drug Details
            const Text(
              "Step 1: Drug Details",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: drugNameController,
              decoration: InputDecoration(
                labelText: 'Drug Name',
                hintText: 'Enter the name of the drug',
                hintStyle: const TextStyle(color: AppTheme.blackColor),
                labelStyle: const TextStyle(color: AppTheme.blackColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: dosageController,
              decoration: InputDecoration(
                labelText: 'Dosage (Optional)',
                hintText: 'Enter dosage (e.g., 50mg)',
                hintStyle: const TextStyle(color: AppTheme.blackColor),
                labelStyle: const TextStyle(color: AppTheme.blackColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 30.0),

            // Step 2: Schedule
            const Text(
              "Step 2: Schedule",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            // Frequency options
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

            // Show custom frequency fields when 'Custom' is selected
            if (isCustomFrequency) ...[
              const SizedBox(height: 10.0),
              TextField(
                controller: pillsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'How many pills?',
                  hintText: 'Enter number of pills',
                  hintStyle: const TextStyle(color: AppTheme.blackColor),
                  labelStyle: const TextStyle(color: AppTheme.blackColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
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
                      decoration: InputDecoration(
                        labelText: 'Enter interval (e.g., 6)',
                        hintText: 'e.g., 6 hours or days',
                        hintStyle: const TextStyle(color: AppTheme.blackColor),
                        labelStyle: const TextStyle(color: AppTheme.blackColor),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: frequencyUnit,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0),
                        ),
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

            // Step 3: Duration and Notes
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
                    decoration: InputDecoration(
                      labelText: 'Enter duration',
                      hintText: 'e.g., 30',
                      hintStyle: const TextStyle(color: AppTheme.blackColor),
                      labelStyle: const TextStyle(color: AppTheme.blackColor),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    enabled:
                        !isIndefinite, // Disable input when indefinite is selected
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: durationUnit,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: isIndefinite
                        ? null // Disable dropdown when "Indefinite" is selected
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
                const Text(
                  'Indefinite',
                  style: TextStyle(color: AppTheme.blackColor),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any special instructions?',
                hintStyle: const TextStyle(color: AppTheme.blackColor),
                labelStyle: const TextStyle(color: AppTheme.blackColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // Save medication logic goes here
              },
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
