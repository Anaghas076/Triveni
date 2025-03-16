import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/productdemo.dart';
import 'package:user_triveni/main.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Map<String, dynamic>> products = [];

  Future<void> fetchproduct() async {
    try {
      final response =
          await supabase.from('tbl_product').select("*, tbl_subcategory(*)");
      setState(() {
        products = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchproduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 80,
      //   backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      //   title: TextFormField(
      //     controller: SearchController(),
      //     style: const TextStyle(
      //         color: Color.fromARGB(255, 240, 240, 242),
      //         fontWeight: FontWeight.bold),
      //     decoration: InputDecoration(
      //       enabledBorder: OutlineInputBorder(
      //         borderRadius: BorderRadius.circular(30),
      //         borderSide: const BorderSide(
      //           color: Colors.white,
      //         ),
      //       ),
      //       prefixIcon: const Icon(
      //         Icons.search,
      //         color: Colors.white,
      //       ),
      //       hintText: "Search",
      //       hintStyle: const TextStyle(
      //         color: Colors.white,
      //       ),
      //       border: const OutlineInputBorder(),
      //     ),
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5, // Space between columns
            mainAxisSpacing: 5, // Space between rows
            childAspectRatio: 0.62, // Adjust card height vs width ratio
          ),
          itemBuilder: (context, index) {
            final data = products[index];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                // Rounded corners
              ),
              child: Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Productdemo(
                            product: data,
                          ),
                        ));
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            image: DecorationImage(
                              image: NetworkImage(data['product_photo']),
                              fit: BoxFit.cover,
                            )),
                      ),
                      Text(data['product_name']),
                      // Text(data['product_code']),
                      Text(data['product_price'].toString()),
                      Text(
                        data['product_type'],
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      Text(data['product_description']),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: products.length,
        ),
      ),
    );
  }
}
