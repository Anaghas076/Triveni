import 'package:artisan_triveni/Screen/registerpage.dart';
import 'package:flutter/material.dart';
import 'package:artisan_triveni/Screen/loginpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Registerpage());
  }
}
