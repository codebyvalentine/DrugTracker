import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _gender;
  DateTime? _dateOfBirth;
  String? _weight;
  String _weightUnit = 'kg';
  String? _height;

  //bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _emailController.text = user.email ?? '';
          _gender = data['gender'];
          _dateOfBirth = (data['dateOfBirth'] as Timestamp?)?.toDate();
          _weight = data['weight'];
          _weightUnit = data['weightUnit'] ?? 'kg';
          _height = data['height'];
          setState(() {});
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load user data: $e")),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final User? user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).set({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'gender': _gender,
            'dateOfBirth': _dateOfBirth,
            'weight': _weight,
            'weightUnit': _weightUnit,
            'height': _height,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully")),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update profile: $e")),
          );
        }
      }
    }
  }

  // Future<void> _saveProfile() async {
  //   final User? user = _auth.currentUser;
  //   if (user != null) {
  //     try {
  //       await _firestore.collection('users').doc(user.uid).update({
  //         'firstName': _firstNameController.text,
  //         'lastName': _lastNameController.text,
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Profile updated successfully")),
  //       );
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to update profile: $e")),
  //       );
  //     }
  //   }
  // }

  // Future<void> _loadUserData() async {
  //   final User? user = _auth.currentUser;
  //   if (user != null) {
  //     try {
  //       DocumentSnapshot userDoc =
  //           await _firestore.collection('users').doc(user.uid).get();
  //       if (userDoc.exists) {
  //         Map<String, dynamic> userData =
  //             userDoc.data() as Map<String, dynamic>;
  //         setState(() {
  //           _firstNameController.text = userData['firstName'] ?? '';
  //           _lastNameController.text = userData['lastName'] ?? '';
  //           _emailController.text = user.email ?? '';
  //           _isLoading = false;
  //         });
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("User data not found")),
  //         );
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to load user data: $e")),
  //       );
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const LoginScreen()),
  //     );
  //   }
  // }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

// profile deletes but the medicatinos does not delete alongside
  Future<void> _deleteProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final QuerySnapshot medicationsSnapshot = await _firestore
            .collection('medications')
            .doc(user.uid)
            .collection('userMedications')
            .get();
        for (final DocumentSnapshot doc in medicationsSnapshot.docs) {
          await doc.reference.delete();
        }

        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile deleted successfully")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete profile: $e")),
        );
      }
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16.0),
              // Gender Selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: _gender,
                items: ['Female', 'Male', 'Prefer not to say']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Date of Birth
              TextFormField(
                decoration: InputDecoration(labelText: 'Date of Birth'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateOfBirth = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _dateOfBirth == null
                      ? ''
                      : "${_dateOfBirth!.month}/${_dateOfBirth!.day}/${_dateOfBirth!.year}",
                ),
                validator: (value) {
                  if (_dateOfBirth == null) {
                    return 'Please select your date of birth';
                  }
                  return null;
                    },
              ),
              const SizedBox(height: 16.0),
              // Weight
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Weight'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _weight = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _weightUnit,
                    items: ['kg', 'lb']
                        .map((label) => DropdownMenuItem(
                              child: Text(label),
                                                            value: label,
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _weightUnit = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Height
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _height = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
               const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  // Add your logout functionality here
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Profile'),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.logout),
  //           tooltip: 'Logout',
  //           onPressed: () async {
  //             final bool? confirm = await showDialog<bool>(
  //               context: context,
  //               builder: (context) {
  //                 return AlertDialog(
  //                   title: const Text('Logout'),
  //                   content: const Text('Are you sure you want to log out?'),
  //                   actions: [
  //                     TextButton(
  //                       onPressed: () => Navigator.of(context).pop(false),
  //                       child: const Text('Cancel'),
  //                     ),
  //                     TextButton(
  //                       onPressed: () => Navigator.of(context).pop(true),
  //                       child: const Text('Logout'),
  //                     ),
  //                   ],
  //                 );
  //               },
  //             );

  //             if (confirm == true) {
  //               _logout();
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //     body: _isLoading
  //         ? const Center(child: CircularProgressIndicator())
  //         : Padding(
  //             padding: const EdgeInsets.all(20.0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 Text(
  //                   'Hello ${_firstNameController.text} ${_lastNameController.text}',
  //                   style: const TextStyle(
  //                       fontSize: 24.0, fontWeight: FontWeight.bold),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 30.0),
  //                 TextFormField(
  //                   controller: _firstNameController,
  //                   decoration: const InputDecoration(labelText: 'First Name'),
  //                 ),
  //                 const SizedBox(height: 16.0),
  //                 TextFormField(
  //                   controller: _lastNameController,
  //                   decoration: const InputDecoration(labelText: 'Last Name'),
  //                 ),
  //                 const SizedBox(height: 16.0),
  //                 TextFormField(
  //                   controller: _emailController,
  //                   readOnly: true,
  //                   decoration: const InputDecoration(labelText: 'Email'),
  //                 ),
  //                 const SizedBox(height: 30.0),
  //                 ElevatedButton(
  //                   onPressed: _saveProfile,
  //                   child: const Text(
  //                     'Save Profile',
  //                     style: TextStyle(
  //                         fontSize: 16.0, fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 30.0),
  //                 ElevatedButton(
  //                   onPressed: () async {
  //                     final bool? confirm = await showDialog<bool>(
  //                       context: context,
  //                       builder: (context) {
  //                         return AlertDialog(
  //                           title: const Text('Delete Profile'),
  //                           content: const Text(
  //                               'Are you sure you want to delete your profile? This action cannot be undone.'),
  //                           actions: [
  //                             TextButton(
  //                               onPressed: () =>
  //                                   Navigator.of(context).pop(false),
  //                               child: const Text('Cancel'),
  //                             ),
  //                             TextButton(
  //                               onPressed: () =>
  //                                   Navigator.of(context).pop(true),
  //                               child: const Text('Delete'),
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     );

  //                     if (confirm == true) {
  //                       _deleteProfile();
  //                     }
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.red,
  //                   ),
  //                   child: const Text(
  //                     'Delete My Profile',
  //                     style: TextStyle(
  //                         fontSize: 16.0, fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //   );
  // }