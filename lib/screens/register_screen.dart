import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
            const SizedBox(height: 30.0),
            const TextField(
              decoration: InputDecoration(
                labelText: "Name",
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
              ),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // Add Register Logic
              },
              child: const Text("Register Now"),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text("Already have an account? Login now"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
