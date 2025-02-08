import 'package:flutter/material.dart';
import 'package:weaver_triveni/Screen/homepage.dart';
import 'package:weaver_triveni/Screen/registerpage.dart';

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
