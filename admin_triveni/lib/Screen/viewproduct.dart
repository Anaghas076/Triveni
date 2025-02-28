import 'package:admin_triveni/Screen/addproduct.dart';
import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Viewproduct extends StatefulWidget {
  const Viewproduct({super.key});

  @override
  State<Viewproduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<Viewproduct> {
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

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_product').delete().eq('product_id', id);
      fetchproduct();
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10, // Space between columns
          mainAxisSpacing: 10, // Space between rows
          childAspectRatio: .7, // Adjust card height vs width ratio
        ),
        itemBuilder: (context, index) {
          final data = products[index];

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Column(
              children: [
                Container(
                  height: 300,
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
                Text(data['product_code']),
                Text(data['product_price']),
                Text(data['product_type']),
                Text(data['product_description']),
              ],
            ),
          );
        },
        itemCount: products.length,
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddProduct(),
              ),
            );
          },
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
