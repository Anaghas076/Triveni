import 'package:artisan_triveni/Screen/adddesign.dart';

import 'package:artisan_triveni/Screen/homecontent.dart';

import 'package:artisan_triveni/Screen/loginpage.dart';
import 'package:artisan_triveni/Screen/order.dart';
import 'package:artisan_triveni/Screen/profile.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  // List of pages for bottom navigation
  final List<Widget> pageContent = [
    Homecontent(), // New HomeScreen widget
    Profile(), // Dummy category page
    Order(),
    AddDesign(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.yellow,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ));
          },
        ),
      ),
      body: pageContent[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        // Set the selected index// Color of unselected icons
        type: BottomNavigationBarType.fixed, // Ensure all icons are visible
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "My Account"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "My Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.design_services), label: "My Designs"),
        ],
        selectedItemColor:
            const Color.fromARGB(255, 241, 233, 7), // Color of selected icon
        unselectedItemColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }
}
