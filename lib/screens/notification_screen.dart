import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notificationProvider.notifications.isEmpty
          ? const Center(
        child: Text('No notifications yet.'),
      )
          : ListView.builder(
        itemCount: notificationProvider.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationProvider.notifications[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(notification['title'] ?? 'No Title'),
              subtitle: Text(notification['body'] ?? 'No Body'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  notificationProvider.removeNotification(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
