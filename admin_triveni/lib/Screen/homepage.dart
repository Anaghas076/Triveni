import 'package:admin_triveni/Screen/acceptedlist.dart';
import 'package:admin_triveni/Screen/account.dart';
import 'package:admin_triveni/Screen/attribute.dart';
import 'package:admin_triveni/Screen/booking.dart';
import 'package:admin_triveni/Screen/category.dart';
import 'package:admin_triveni/Screen/complaint.dart';
import 'package:admin_triveni/Screen/dashboard.dart';
import 'package:admin_triveni/Screen/district.dart';
import 'package:admin_triveni/Screen/pattribute.dart';
import 'package:admin_triveni/Screen/product.dart';
import 'package:admin_triveni/Screen/rejectedlist.dart';
import 'package:admin_triveni/Screen/subcategory.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  List<String> pageName = [
    'Dashboard',
    'Account',
    'District',
    'Category',
    'Subcategory',
    'Attribute',
    'Pattribute',
    'Product',
    'Booking',
    'Complaint',
    'AcceptedList',
    'RejectedList',
  ];

  List<IconData> pageIcon = [
    Icons.home,
    Icons.supervised_user_circle,
    Icons.location_city,
    Icons.category_outlined,
    Icons.subdirectory_arrow_left,
    Icons.edit_attributes,
    Icons.add,
    Icons.subject,
    Icons.online_prediction_sharp,
    Icons.sync_problem,
    Icons.person_add_alt_sharp,
    Icons.person_remove_sharp,
  ];

  List<Widget> pageContent = [
    Dashboard(),
    Account(),
    District(),
    Category(),
    Subcategory(),
    Attribute(),
    Pattribute(),
    Product(),
    Booking(),
    Complaint(),
    AcceptedList(),
    RejectedList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.yellowAccent,
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
                    leading: Icon(pageIcon[index]),
                    title: Text(pageName[index]),
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
