import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/custom.dart';

import 'package:user_triveni/main.dart'; // Import your Supabase connection

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<Map<String, dynamic>> cartItems = [];

  Future<void> fetchCartItems() async {
    try {
      final response =
          await supabase.from('tbl_cart').select(" *, tbl_product(*)");
      setState(() {
        cartItems = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_cart').delete().eq('cart_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchCartItems();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "My Cart",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final data = cartItems[index];
                final product = data['tbl_product'] ?? {}; // Handle null cases

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // Product Image & Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product['product_photo'] ?? "",
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image,
                                        size: 80, color: Colors.grey),
                              ),
                            ),
                            SizedBox(width: 20),

                            // Product Details in Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['product_name'] ?? "Product Name",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Price: ₹${product['product_price'] ?? '0'}",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    data['cart_quantity'].toString(),
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Total: 1000",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        // Buttons: Remove & Custom
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                delete(data['cart_id']);
                              },
                              child: Text("Remove"),
                            ),
                            product['product_type'] == 'Custom'
                                ? ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Custom(
                                            cartId: data['cart_id'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text("Customize"),
                                  )
                                : Container()
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartItems.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(15),
              child: SizedBox(
                width: 20,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 23, 2, 62),
                  ),
                  onPressed: () {
                    // Checkout();
                  },
                  child: Text("Checkout",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            )
          : null,
    );
  }
}
