import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';
import 'package:user_triveni/screen/cart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:user_triveni/screen/homecontent.dart';
import 'package:user_triveni/screen/myorder.dart';
import 'package:user_triveni/screen/profile.dart';
import 'package:user_triveni/screen/search.dart';

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
    Myorder(),
    Search(),
  ];

  Future<void> saveFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await supabase.from('tbl_user').update({'fcm_token': fcmToken}).eq(
            'user_id', supabase.auth.currentUser!.id);
      }
      print("FCM GENERATED");
      print(fcmToken);
    } catch (e) {
      print("FCM Token Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    saveFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 80,
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset("asset/Logo.jpeg"),
        ),
        // leading: CircleAvatar(
        //   child: Image.asset("asset/Logo.jpeg"),
        // ),
        // title: TextFormField(
        //   style: const TextStyle(
        //       color: Color.fromARGB(255, 240, 240, 242),
        //       fontWeight: FontWeight.bold),
        //   decoration: InputDecoration(
        //     enabledBorder: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(30),
        //       borderSide: const BorderSide(
        //         color: Colors.white,
        //       ),
        //     ),
        //     prefixIcon: const Icon(
        //       Icons.search,
        //       color: Colors.white,
        //     ),
        //     hintText: "Search",
        //     hintStyle: const TextStyle(
        //       color: Colors.white,
        //     ),
        //     border: const OutlineInputBorder(),
        //   ),
        // ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.yellow,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(),
                  ));
            },
          ),
        ],
      ),
      body: pageContent[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        // Set the selected index// Color of unselected icons
        type: BottomNavigationBarType.fixed, // Ensure all icons are visible
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "My Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "My Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
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
