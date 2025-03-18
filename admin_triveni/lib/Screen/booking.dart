import 'package:admin_triveni/Screen/reply.dart';
import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Booking extends StatefulWidget {
  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  List<Map<String, dynamic>> ordersData = [];

  Future<void> fetchAllOrders() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              "*, tbl_users(user_name, user_email), tbl_cart(*, tbl_product(*))")
          .order('booking_id', ascending: false);

      List<Map<String, dynamic>> orders = [];

      for (var data in response) {
        final cart = data['tbl_cart'] ?? [];
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
            'product_code': cartData['tbl_product']['product_code'],
            'total': total,
          });
        }

        orders.add({
          'booking_id': data['booking_id'],
          'current_date': data['current_date'],
          'booking_amount': data['booking_amount'],
          'booking_status': data['booking_status'],
          'user_name': data['tbl_users']['user_name'],
          'user_email': data['tbl_users']['user_email'],
          'cart': cartItems,
        });
      }

      setState(() {
        ordersData = orders;
      });
    } catch (e) {
      print("Error fetching orders: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All User Orders")),
      body: ordersData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: ordersData.length,
              itemBuilder: (context, index) {
                final order = ordersData[index];
                final cartItems = order['cart'];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Details
                        Text(
                          "Customer: ${order['user_name']} (${order['user_email']})",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text("Order ID: ${order['booking_id']}",
                            style: TextStyle(fontSize: 14)),
                        Text("Date: ${order['current_date']}",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text("Total Amount: ₹${order['booking_amount']}",
                            style:
                                TextStyle(fontSize: 14, color: Colors.green)),
                        SizedBox(height: 10),

                        // Cart Items List
                        Column(
                          children: cartItems.map<Widget>((cartItem) {
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
                                  Text("Code: ${cartItem['product_code']}"),
                                  Text("QTY: ${cartItem['cart_quantity']}"),
                                ],
                              ),
                              trailing: Text(
                                "₹${cartItem['total']}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
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
                                // Navigate to Post Complaint Page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Reply(),
                                  ),
                                );
                              },
                              child: Text(
                                "Complaint",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              order['booking_status'] == 1
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
