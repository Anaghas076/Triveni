import 'package:admin_triveni/Screen/aacceptedlist.dart';

import 'package:admin_triveni/Screen/arejectedlist.dart';

import 'package:admin_triveni/Screen/attribute.dart';
import 'package:admin_triveni/Screen/booking.dart';
import 'package:admin_triveni/Screen/category.dart';
import 'package:admin_triveni/Screen/complaint.dart';
import 'package:admin_triveni/Screen/dashboard.dart';

import 'package:admin_triveni/Screen/subcategory.dart';
import 'package:admin_triveni/Screen/userlist.dart';
import 'package:admin_triveni/Screen/viewproduct.dart';
import 'package:admin_triveni/Screen/wacceptedlist.dart';
import 'package:admin_triveni/Screen/wrejectedlist.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;
//start
  List<String> pageName = [
    'Dashboard',
    'Category',
    'Subcategory',
    'Attribute',
    'Product',
    'Booking',
    'Complaint',
    'UserList',
    'WAcceptedList',
    'WrejectedList',
    'AAcceptedList',
    'ArejectedList',
  ];

  List<IconData> pageIcon = [
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
    Icons.person_add_alt_sharp,
  ];

  List<Widget> pageContent = [
    Dashboard(),
    Category(),
    Subcategory(),
    Attribute(),
    Viewproduct(),
    Booking(),
    Complaint(),
    Userlist(),
    Wacceptedlist(),
    Wrejectectedlist(),
    Aacceptedlist(),
    Arejectedlist(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Admin Dashboard'),
        titleTextStyle: TextStyle(
            color: const Color.fromARGB(255, 54, 3, 116), fontSize: 32),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              // decoration: BoxDecoration(
              color: Colors.white, //side bar
              // shape: BoxShape.rectangle, ),
              child: ListView.builder(
                itemCount: pageName.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      setState(() {
                        print(index);
                        selectedIndex = index;
                      });
                    },
                    leading: Icon(
                      pageIcon[index],
                      color: const Color.fromARGB(255, 54, 3, 116),
                    ),
                    title: Text(pageName[index]),
                    textColor: const Color.fromARGB(255, 54, 3, 116),
                    titleTextStyle: TextStyle(fontSize: 18),
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: pageContent[selectedIndex],
            ),
          )
        ],
      ),
    );
  }
}
