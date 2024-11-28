import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  final List<Map<String, String>> _notifications = [];

  List<Map<String, String>> get notifications => List.unmodifiable(_notifications);

  void addNotification(String title, String body) {
    _notifications.add({'title': title, 'body': body});
    notifyListeners(); // Notify listeners of the change
  }

  void removeNotification(int index) {
    _notifications.removeAt(index);
    notifyListeners(); // Notify listeners of the change
  }
}
