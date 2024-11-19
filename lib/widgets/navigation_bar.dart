import 'package:flutter/material.dart';
import 'package:main/utils/theme.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  CustomNavigationBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      elevation: 4.0,
      backgroundColor: AppTheme.lightBackgroundGreen,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 14.0,
      unselectedFontSize: 12.0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: "Add",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: "My Meds",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb),
          label: "Zira AI",
        ),
      ],
    );
  }
}
