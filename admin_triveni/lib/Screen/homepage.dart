import 'package:admin_triveni/Screen/aacceptedlist.dart';
import 'package:admin_triveni/Screen/arejectedlist.dart';
import 'package:admin_triveni/Screen/artisanlist.dart';

import 'package:admin_triveni/Screen/booking.dart';
import 'package:admin_triveni/Screen/category.dart';
import 'package:admin_triveni/Screen/complaint.dart';
import 'package:admin_triveni/Screen/dashboard.dart';
import 'package:admin_triveni/Screen/report.dart';

import 'package:admin_triveni/Screen/subcategory.dart';
import 'package:admin_triveni/Screen/userlist.dart';
import 'package:admin_triveni/Screen/viewproduct.dart';
import 'package:admin_triveni/Screen/wacceptedlist.dart';
import 'package:admin_triveni/Screen/weaverlist.dart';
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
    'Product',
    'Booking',
    'Complaint',
    'Report',
    'UserList',
    'WeaverList',
    'WacceptedList',
    'WrejectedList',
    'ArtisanList',
    'AacceptedList',
    'ArejectedList',
  ];

  List<IconData> pageIcon = [
    Icons.dashboard,
    Icons.category,
    Icons.subdirectory_arrow_left,
    Icons.inventory_2,
    Icons.list_alt,
    Icons.comment,
    Icons.report,
    Icons.group,
    Icons.content_cut,
    Icons.content_cut_sharp,
    Icons.content_cut_rounded,
    Icons.palette,
    Icons.palette_sharp,
    Icons.palette_rounded,
  ];

  List<Widget> pageContent = [
    Dashboard(),
    Category(),
    Subcategory(),
    Viewproduct(),
    Booking(),
    Complaint(),
    CountReport(),
    Userlist(),
    Weaverlist(),
    Wacceptedlist(),
    Wrejectedlist(),
    Artisanlist(),
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
