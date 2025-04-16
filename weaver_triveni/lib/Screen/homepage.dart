import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:weaver_triveni/Screen/daily.dart';
import 'package:weaver_triveni/main.dart';
import 'package:weaver_triveni/screen/dashboard.dart';

import 'package:weaver_triveni/screen/myorder.dart';

import 'package:weaver_triveni/screen/profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  // List of pages for bottom navigation
  final List<Widget> pageContent = [
    Orders(), // New HomeScreen widget
    Profile(), // Dummy category page
    Myorder(),
    DailyWeaver(),
  ];

  Future<void> saveFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await supabase.from('tbl_weaver').update({'fcm_token': fcmToken}).eq(
            'weaver_id', supabase.auth.currentUser!.id);
      }
      print("FCM GENERATED");
      print(fcmToken);
    } catch (e) {
      print("FCM Token Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        title: ListTile(
          leading: CircleAvatar(
            radius: 33,
            backgroundImage: AssetImage("asset/Logo.jpeg"),
          ),
          title: Text(
            "TRIVENI",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
          ),
          subtitle: Text(
            "Handloom with heritage, fashion with soul",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "Expense"),
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
