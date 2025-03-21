import 'package:flutter/material.dart';
import 'package:user_triveni/Component/product_card.dart';

import 'package:user_triveni/Screen/demo.dart';
import 'package:user_triveni/Screen/productdemo.dart';
import 'package:user_triveni/main.dart';

class Homecontent extends StatefulWidget {
  const Homecontent({super.key});

  @override
  State<Homecontent> createState() => _HomecontentState();
}

class _HomecontentState extends State<Homecontent> {
  List<Map<String, dynamic>> categories = [];

  Future<void> fetchCategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categories = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  List<Map<String, dynamic>> products = [];

  Future<void> fetchProducts() async {
    try {
      final response = await supabase
          .from('tbl_product')
          .select()
          .order('created_at', ascending: false)
          .limit(6);
      setState(() {
        products = response;
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategory();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Categorized By Section
          SizedBox(height: 10),
          Center(
            child: Text(
              "Categorized by",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),

          // Categories Grid
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final data = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Productdemo(product: data),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(data['category_photo']),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(data['category_name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 5),

          Center(
            child: Text(
              "Customized Product",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: .6),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(productData: products[index]);
            },
          )
        ],
      ),
    );
  }
}
