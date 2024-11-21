import 'package:flutter/material.dart';
import 'package:main/utils/theme.dart';
import '../screens/profile_screen.dart';
import '../screens/notification_screen.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final bool isCloseButton;
  final VoidCallback? onBack;

  const TopBar({super.key, 
    this.showBackButton = false,
    this.isCloseButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.lightBackgroundGreen,
      elevation: 4.0,
      iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      leading: showBackButton || isCloseButton
          ? IconButton(
              icon: Icon(isCloseButton ? Icons.close : Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      actions: [
        if (!showBackButton && !isCloseButton)
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        if (!showBackButton && !isCloseButton)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
