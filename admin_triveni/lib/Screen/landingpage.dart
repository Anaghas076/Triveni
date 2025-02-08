import 'package:flutter/material.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Navigation Bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Store",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    NavBarItem(title: "Home"),
                    NavBarItem(title: "About Us"),
                    NavBarItem(title: "Shop"),
                    NavBarItem(title: "Contact"),
                  ],
                ),
              ],
            ),
          ),

          // Hero Section
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade200, Colors.pink.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OUTFIT OF THE DAY",
                    style: TextStyle(fontSize: 14, letterSpacing: 2),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "ALL YOUR\nSTYLES ARE HERE",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Find the best styles for every season, handpicked just for you. Explore now!",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text("BUY NOW"),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 40),

                  // Product Showcase
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProductItem(title: "Casual Jacket", price: "\$125"),
                      SizedBox(width: 20),
                      ProductItem(title: "Pink Jacket", price: "\$110"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Navigation Item
class NavBarItem extends StatelessWidget {
  final String title;
  NavBarItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// Product Item
class ProductItem extends StatelessWidget {
  final String title;
  final String price;

  ProductItem({required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            color: Colors.grey[300], // Placeholder for image
          ),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(price, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
