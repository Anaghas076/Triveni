import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weaver_triveni/Screen/landingpage.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://tmmmwkncepkakfwcxbgh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtbW13a25jZXBrYWtmd2N4YmdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMDQxODYsImV4cCI6MjA1MjY4MDE4Nn0.O2iyVTuj_XSpP3JaM8m2g-VmwaVCJ1Gb1Z1qz9R-6qA',
  );

  runApp(MainApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Landingpage());
  }
}
