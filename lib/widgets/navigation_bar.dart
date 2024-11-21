import 'package:flutter/material.dart';
import 'package:main/utils/theme.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const CustomNavigationBar({super.key, 
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabChanged,
      type: BottomNavigationBarType.fixed,
      elevation: 4.0, // Adds slight shadow for elevation
      backgroundColor: AppTheme.lightBackgroundGreen,
      selectedItemColor: Theme.of(context).primaryColor, // Modern green
      unselectedItemColor: Colors.grey, // Neutral color for unselected items
      selectedFontSize: 14.0, // Slightly larger font for selected
      unselectedFontSize: 12.0, // Slightly smaller font for unselected
      items: const [
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
