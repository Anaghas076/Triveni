import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/payment.dart';
import 'package:user_triveni/Screen/postcomplaint.dart';
import 'package:user_triveni/main.dart';
import 'package:intl/intl.dart';

class Myorder extends StatefulWidget {
  @override
  _MybookingDataState createState() => _MybookingDataState();
}

class _MybookingDataState extends State<Myorder> {
  List<Map<String, dynamic>> bookingData = [];

  Future<void> fetchBooking() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      List<Map<String, dynamic>> orders = [];

      final response = await supabase
          .from('tbl_booking')
          .select(" *, tbl_cart(*, tbl_product(*))")
          .gte('booking_status', 1)
          .eq('user_id', user.id);

      for (var data in response) {
        final cart = data['tbl_cart'];
        List<Map<String, dynamic>> cartItems = [];

        for (var cartData in cart) {
          int total = cartData['cart_quantity'] *
              cartData['tbl_product']['product_price'];
          cartItems.add({
            'cart_id': cartData['cart_id'],
            'cart_quantity': cartData['cart_quantity'],
            'product_id': cartData['tbl_product']['product_id'],
            'product_name': cartData['tbl_product']['product_name'],
            'product_photo': cartData['tbl_product']['product_photo'],
            'product_price': cartData['tbl_product']['product_price'],
            'product_code': cartData['tbl_product']['product_code'],
            'total': total,
          });
        }

        orders.add({
          'booking_id': data['booking_id'],
          'booking_status': data['booking_status'],
          'booking_amount':
              data['booking_amount'], // Ensure this field is fetched
          'created_at': data['created_at'], // Fetch order date
          'cart': cartItems,
        });
      }

      setState(() {
        bookingData = orders;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> order(int bookingId, int status) async {
    try {
      await supabase
          .from('tbl_booking')
          .update({'booking_status': status}).eq('booking_id', bookingId);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Payment(),
          ));
      fetchBooking();
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBooking();
  }

  String formatDate(String timestamp) {
    DateTime parsedDate = DateTime.parse(timestamp); // Convert to DateTime
    return DateFormat('dd-MM-yyyy').format(parsedDate); // Format the date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bookingData.isEmpty
          ? Center(child: Text("No orders found"))
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: bookingData.length,
              itemBuilder: (context, index) {
                final bookingItems = bookingData[index];
                final cartData = bookingItems['cart'];

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
                        Text(
                          "Date: ${formatDate(bookingItems['created_at'])}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),

                        SizedBox(height: 10),

                        // Cart Items
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
                                  Text(
                                      "Code: ${cartItem['product_code'] ?? 'N/A'}"),
                                  Text("QTY: ${cartItem['cart_quantity']}"),
                                ],
                              ),
                              trailing: Column(
                                children: [
                                  Text(
                                    "₹${cartItem['total']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (bookingItems['booking_status'] == 12)
                                    SizedBox(
                                      width: 110,
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Postcomplaint(
                                                          productId: cartItem[
                                                              'product_id'])));
                                        },
                                        child: Text(
                                          "Complaint",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (bookingItems['booking_status'] == 9)
                              ElevatedButton(
                                onPressed: () {
                                  order(bookingItems['booking_id'], 10);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Payment(),
                                      ));
                                },
                                child: Text(
                                  "Pay Amount",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              bookingItems['booking_status'] == 1
                                  ? "Ordered"
                                  : bookingItems['booking_status'] == 2
                                      ? "Publish to weaver"
                                      : bookingItems['booking_status'] == 3
                                          ? "Weaver Accepted"
                                          : bookingItems['booking_status'] == 4
                                              ? "Weaver Completed"
                                              : bookingItems[
                                                          'booking_status'] ==
                                                      5
                                                  ? "Publish to artisan"
                                                  : bookingItems[
                                                              'booking_status'] ==
                                                          6
                                                      ? "Artisan Accepted"
                                                      : bookingItems[
                                                                  'booking_status'] ==
                                                              7
                                                          ? "Artisan Completed"
                                                          : bookingItems[
                                                                      'booking_status'] ==
                                                                  8
                                                              ? "Item packed"
                                                              : bookingItems[
                                                                          'booking_status'] ==
                                                                      10
                                                                  ? "Payed"
                                                                  : bookingItems[
                                                                              'booking_status'] ==
                                                                          11
                                                                      ? "Shipped"
                                                                      : bookingItems['booking_status'] ==
                                                                              12
                                                                          ? "Delivered"
                                                                          : " ", // Default case if status doesn't match
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            Text(
                              " Total Amount : ₹  ${bookingItems['booking_amount']}",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
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
