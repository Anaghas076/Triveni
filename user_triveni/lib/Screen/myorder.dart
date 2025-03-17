import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/postcomplaint.dart';
import 'package:user_triveni/Screen/productdemo.dart';
import 'package:user_triveni/main.dart';

class Myorder extends StatefulWidget {
  @override
  _MybookingDataState createState() => _MybookingDataState();
}

class _MybookingDataState extends State<Myorder> {
  List<Map<String, dynamic>> bookingData = [];
  Future<void> fetchCartItems() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Fetch the user's active booking
      await supabase
          .from('tbl_booking')
          .select()
          .eq('user_id', user.id)
          .eq('booking_status', 1)
          .maybeSingle();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchBooking() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      List<Map<String, dynamic>> orders = [];

      final response = await supabase
          .from('tbl_booking')
          .select(" * ,tbl_cart(*,tbl_product(*))")
          .eq('booking_status', 1)
          .eq('user_id', supabase.auth.currentUser!.id);

      for (var data in response) {
        final cart = data['tbl_cart'];
        List<Map<String, dynamic>> cartItems = [];
        for (var cartData in cart) {
          int total = cartData['cart_quantity'] *
              cartData['tbl_product']['product_price'];
          cartItems.add({
            'cart_id': cartData['cart_id'],
            'cart_quantity': cartData['cart_quantity'],
            'product_name': cartData['tbl_product']['product_name'],
            'product_photo': cartData['tbl_product']['product_photo'],
            'product_price': cartData['tbl_product']['product_price'],
            'product_code': cartData['tbl_product']['product_price'],
            'total': total
          });
        }
        orders.add({
          'booking_id': data['booking_id'],
          'booking_status': data['booking_status'],
          'cart': cartItems,
        });
        // Map<String, dynamic> cart = {
        //   'product':
        // };
      }

      print(orders);

      setState(() {
        bookingData = orders;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchBooking();
    fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: bookingData.length,
        itemBuilder: (context, index) {
          final bookingItems = bookingData[index];
          final cartData = bookingData[index]['cart'];
          print("Booking data: $bookingItems");
          print("Cart: $cartData");
          // final cartItems = bookingItems['tbl_cart'] ?? [];
          // final productItems = bookingItems['tbl_cart'] ?? [];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Details
                  // Text(
                  //   "Order ID: ${bookingItems['booking_id']}",
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                  SizedBox(height: 5),
                  Text(
                    "Date: ${bookingItems['current_date']}",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Total Amount: ₹${bookingItems['booking_amount']}",
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  SizedBox(height: 10),

                  // Cart Items List
                  Column(
                    children: cartData.map<Widget>((cartItem) {
                      return ListTile(
                        leading: Image.network(
                          cartItem['product_photo'] ?? "",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported, size: 50),
                        ),
                        title: Text(
                          cartItem['product_name'] ?? "Product Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Code: ${cartItem['product_price']}"),
                            Text("QTY: ${cartItem['cart_quantity']}"),
                          ],
                        ),
                        trailing: Text(
                          "₹${cartItem['total']}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Postcomplaint()));
                        },
                        child: Text(
                          "Complaint",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        bookingItems['booking_status'] == 1
                            ? "Active"
                            : "Completed",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
