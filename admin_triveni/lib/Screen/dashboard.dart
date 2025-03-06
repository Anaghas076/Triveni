import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.4,
        ),
        children: [
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.person,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Weaver",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "10",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.palette,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Artisan",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "10",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.people,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "User",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "10",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Product",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "10",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.design_services,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Design",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "10",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.architecture,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Hello ",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Triveni Menon",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
