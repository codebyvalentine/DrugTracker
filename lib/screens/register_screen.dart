import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Create an account",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.0),
            TextField(
              decoration: InputDecoration(
                labelText: "Name",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // Add Register Logic
              },
              child: Text("Register Now"),
            ),
            SizedBox(height: 20.0),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Already have an account? Login now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
