import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weaver_triveni/screen/homepage.dart';
import 'package:weaver_triveni/screen/landingpage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Required for background handling
  print("Handling a background message: ${message.messageId}");
}

// Initialize local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://tmmmwkncepkakfwcxbgh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbW13a25jZXBrYWtmd2N4YmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMDQxODYsImV4cCI6MjA1MjY4MDE4Nn0.O2iyVTuj_XSpP3JaM8m2g-VmwaVCJ1Gb1Z1qz9R-6qA',
  );
  await requestNotificationPermission();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.notification?.title}');
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  });

  // Handle notification when app is opened from a terminated state
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification opened: ${message.notification?.title}');
  });
  runApp(MainApp());
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User denied permission');
  }
}

void _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id',
    'Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
    notificationDetails,
  );
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: Landingpage());
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state
    if (session != null) {
      return Homepage(); // Replace with your home screen widget
    } else {
      return Landingpage(); // Replace with your auth page widget
    }
  }
}
