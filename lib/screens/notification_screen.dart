import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        isCloseButton: true, // Enable the close (X) button
        onBack: () {
          Navigator.pop(context); // Close the notification screen
        },
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount:
            10, // Replace with actual notification count from a data source
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.green),
              title: Text("Notification Title $index"),
              subtitle: Text("This is the description of notification $index."),
              trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
              onTap: () {
                // Handle notification tap action
              },
            ),
          );
        },
      ),
    );
  }
}
