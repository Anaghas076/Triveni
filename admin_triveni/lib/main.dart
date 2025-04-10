// Make sure you import your Dashboard screen
import 'package:admin_triveni/screen/homepage.dart';
import 'package:admin_triveni/screen/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://tmmmwkncepkakfwcxbgh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbW13a25jZXBrYWtmd2N4YmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMDQxODYsImV4cCI6MjA1MjY4MDE4Nn0.O2iyVTuj_XSpP3JaM8m2g-VmwaVCJ1Gb1Z1qz9R-6qA',
  );

  // Run the app
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is already logged in
    final user = supabase.auth.currentUser;

    // Navigate to the appropriate page based on authentication status
    return MaterialApp(
      home: user == null
          ? const LoginPage()
          : Homepage(), // Decide the page based on login status
    );
  }
}
