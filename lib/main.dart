import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/home_screen.dart';
import 'providers/notification_provider.dart';
import 'utils/notification_helper.dart';
import 'screens/login_screen.dart';
import '../utils/theme.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
    print('Firebase initialized successfully.');

    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));

    //intialize notification helper
    await NotificationHelper.initialize();

    // Initialize FCM
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    //print FCM token
    String? fcmToken = await messaging.getToken();
    print("FCM Token: $fcmToken");

    // Request notification permissions (iOS only)
    await messaging.requestPermission();

    //Initialize dotenv
    await dotenv.load(fileName: ".env");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        print("Received a message while in foreground: ${notification.title}");
        // Add the notification to the provider
        Provider.of<NotificationProvider>(navigatorKey.currentContext!, listen: false)
            .addNotification(notification.title ?? "No Title", notification.body ?? "No Body");
      }
    });


  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AuthStateHandler(),

    );
  }
}

/// Navigator observer to debug navigation calls
class NavigatorDebugObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('Pushed route: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('Popped route: ${route.settings.name}');
    super.didPop(route, previousRoute);
  }
}

class AuthStateHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // User is logged in
          return const HomeScreen();
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}