import 'package:flutter/material.dart';
import 'package:user_triveni/Component/product_card.dart';
import 'package:user_triveni/Screen/category_search.dart';
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
          .order('created_at', ascending: true)
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
          SizedBox(height: 5),

          // Categories Grid
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Padding(
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
                            backgroundImage:
                                NetworkImage(data['category_photo']),
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
            ),
          ),

          SizedBox(height: 5),

          Center(
            child: Text(
              "Recently Added Product",
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
                crossAxisCount: 2, childAspectRatio: .55),
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
