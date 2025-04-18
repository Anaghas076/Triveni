import 'package:flutter/material.dart';
import 'package:user_triveni/component/product_card.dart';
import 'package:user_triveni/screen/category_search.dart';
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
      List<Map<String, dynamic>> product = [];
      for (var items in response) {
        final response = await supabase
            .from('tbl_review')
            .select()
            .eq('product_id', items['product_id']);

        final reviewsList = List<Map<String, dynamic>>.from(response);

        // Calculate average rating
        double totalRating = 0;
        for (var review in reviewsList) {
          totalRating += double.parse(review['review_rating'].toString());
        }

        double avgRating =
            reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;
        items['rating'] = avgRating;
        product.add(items);
      }
      setState(() {
        products = product;
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
                        builder: (context) =>
                            CategorySearch(category: data['category_id']),
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
              "Recent Product",
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
              crossAxisCount: 2,
              childAspectRatio:
                  _getResponsiveAspectRatio(context), // Dynamic calculation
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(productData: products[index]);
            },
          )
        ],
      ),
    );
  }

  // Function to calculate responsive aspect ratio
  double _getResponsiveAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Example: Adjust ratio based on screen width and desired height
    return (screenWidth / 2) / (screenHeight * 0.43); // Customize as needed
  }
}
