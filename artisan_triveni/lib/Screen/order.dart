import 'package:artisan_triveni/Screen/custom.dart';
import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Booking extends StatefulWidget {
  @override
  _MybookingDataState createState() => _MybookingDataState();
}

class _MybookingDataState extends State<Booking> {
  List<Map<String, dynamic>> bookingData = [];
  int bookingid = 0;
  Future<void> fetchBooking() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              "*, tbl_cart(*, tbl_product(*)), tbl_user(user_name, user_contact)")
          .gte('booking_status', 5); // Ensure only valid bookings are fetched

      List<Map<String, dynamic>> orders = [];

      for (var data in response) {
        final cart = data['tbl_cart'] ?? [];
        List<Map<String, dynamic>> cartItems = [];

        bool hasCustom = false;

        for (var cartData in cart) {
          int total = cartData['cart_quantity'] *
              cartData['tbl_product']['product_price'];

          bool isCustom = false;

          final custom = await supabase
              .from('tbl_customization')
              .count()
              .eq('cart_id', cartData['cart_id']);
          if (custom > 0) {
            isCustom = true;
            hasCustom = true;
          }

          cartItems.add({
            'cart_id': cartData['cart_id'],
            'cart_quantity': cartData['cart_quantity'],
            'product_name': cartData['tbl_product']['product_name'],
            'product_photo': cartData['tbl_product']['product_photo'],
            'product_price': cartData['tbl_product']['product_price'],
            'product_code': cartData['tbl_product']['product_code'],
            'total': total,
            'isCustom': isCustom,
          });
        }

        orders.add({
          'booking_id': data['booking_id'],
          'created_at': data['created_at'],
          'booking_amount': data['booking_amount'],
          'booking_status': data['booking_status'],
          'user_name': data['tbl_user']['user_name'],
          'user_contact': data['tbl_user']['user_contact'],
          'cart': cartItems,
          'hasCustom': hasCustom
        });
      }

      setState(() {
        bookingData = orders;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
    }
  }

  String formatDate(String timestamp) {
    DateTime parsedDate = DateTime.parse(timestamp);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  Future<void> order(int bookingId, int status) async {
    try {
      final artisanId = supabase.auth.currentUser!.id;
      await supabase.from('tbl_booking').update({
        'booking_status': status,
        'artisan_id': artisanId,
      }).eq('booking_id', bookingId);

      fetchBooking();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bookingData.isEmpty
          ? Center(child: Text("No Orders"))
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: bookingData.length,
              itemBuilder: (context, index) {
                final bookingItems = bookingData[index];
                final cartData = bookingData[index]['cart'];

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
                        // Booking Details
                        Text(
                          bookingItems['user_name'] ?? "User Name",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          bookingItems['user_contact'] ?? "User Contact",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Date: ${formatDate(bookingItems['created_at'])}",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
                                  Text("Code: ${cartItem['product_code']}"),
                                  Text("QTY: ${cartItem['cart_quantity']}"),
                                  cartItem['isCustom']
                                      ? ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Viewdesign(
                                                    cartId: cartItem['cart_id'],
                                                    // customs:cartItem['customData']
                                                  ),
                                                ));
                                          },
                                          child: Text("View Design",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)))
                                      : SizedBox()
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (bookingItems['booking_status'] == 5)
                                  ElevatedButton(
                                    onPressed: () {
                                      order(bookingItems['booking_id'], 6);
                                    },
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                if (bookingItems['booking_status'] == 6)
                                  ElevatedButton(
                                    onPressed: () {
                                      order(bookingItems['booking_id'], 7);
                                    },
                                    child: Text(
                                      "Complete",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              bookingItems['booking_status'] == 5
                                  ? "New Order"
                                  : bookingItems['booking_status'] == 6
                                      ? " Accepted"
                                      : bookingItems['booking_status'] >= 7
                                          ? " Completed"
                                          : "Unknown Status", // Default case if status doesn't match
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
