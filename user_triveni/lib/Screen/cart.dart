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
  int bookingid = 0;

  Future<void> fetchCartItems() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;
      print(user.id);
      // Fetch the user's active booking
      final booking = await supabase
          .from('tbl_booking')
          .select('booking_id')
          .eq('user_id', user.id)
          .eq('booking_status', 0)
          .maybeSingle()
          .limit(1);
      print("RESPONSE $booking");
      int bid = booking!['booking_id'];
      setState(() {
        bookingid = bid;
      });
      final response = await supabase
          .from('tbl_cart')
          .select(" *, tbl_product(*)")
          .eq('booking_id', bid)
          .order('cart_id', ascending: false);
      setState(() {
        cartItems = response;
        checkoutTotal = 0; // Reset checkout total before calculation
        for (var item in cartItems) {
          final product = item['tbl_product'] ?? {};
          int qty = item['cart_quantity'];
          int price = product['product_price'];
          int total = qty * price;
          checkoutTotal +=
              total; // Calculate checkout total outside the builder
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_cart').delete().eq('cart_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Removed"),
        backgroundColor: Color.fromARGB(255, 3, 1, 68),
      ));
      fetchCartItems();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateCart(int qty, int cart) async {
    try {
      print("hai");
      print(cart);
      print(qty);
      await supabase
          .from('tbl_cart')
          .update({'cart_quantity': qty}).eq('cart_id', cart);
      print("Success");
      fetchCartItems(); // Refresh the cart after updating
    } catch (e) {
      print("Error updating cart quantity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity. Please try again.')),
      );
    }
  }

  Future<void> checkout(int bookingId, int status) async {
    try {
      await supabase.from('tbl_booking').update({
        'booking_status': status,
        'booking_amount': checkoutTotal
      }).eq('booking_id', bookingId);

      await supabase
          .from('tbl_cart')
          .update({'cart_status': 1}).eq('booking_id', bookingId);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Successfully Ordered"),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ));

      setState(() {
        cartItems.clear();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  int checkoutTotal = 0;

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
          : SingleChildScrollView(
              child: Column(children: [
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final data = cartItems[index];
                    final product =
                        data['tbl_product'] ?? {}; // Handle null cases
                    int qty = data['cart_quantity'];
                    int price = product['product_price'];
                    int total = qty * price;
                    print(product);
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
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.image,
                                            size: 80,
                                            color: Colors.grey),
                                  ),
                                ),
                                SizedBox(width: 20),

                                // Product Details in Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['product_name'] ??
                                            "Product Name",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Price: ₹${product['product_price'].toString()}",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text("Size: ${data['product_size']}"),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 20,
                                            child: ElevatedButton(
                                              onPressed: qty > 1
                                                  ? () {
                                                      int count = qty - 1;
                                                      updateCart(count,
                                                          data['cart_id']);
                                                    }
                                                  : null,
                                              child: Text("-"),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            qty.toString(),
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          SizedBox(width: 5),
                                          SizedBox(
                                            width: 50,
                                            height: 20,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                int count = qty + 1;
                                                updateCart(
                                                    count, data['cart_id']);
                                              },
                                              child: Text("+"),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Total: ${total.toString()}",
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
                                product['product_type'] == 'Customizable'
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
                                        child: Text("Customizable"),
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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Grand Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            checkoutTotal.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
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
                    checkout(bookingid, 1);
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
