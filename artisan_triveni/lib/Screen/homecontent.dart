import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:artisan_triveni/Screen/custom.dart';
import 'package:artisan_triveni/main.dart';
import 'package:intl/intl.dart';

class Orders extends StatefulWidget {
  @override
  _OrdersDataState createState() => _OrdersDataState();
}

class _OrdersDataState extends State<Orders> {
  Map<String, dynamic> artisanid = {};

  int artisancount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchartisan();
    fetchBooking();
    fetchName();
  }

  String formatDate(String timestamp) {
    DateTime parsedDate = DateTime.parse(timestamp);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  List<Map<String, dynamic>> bookingData = [];
  int bookingid = 0;
  Future<void> fetchBooking() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              "*, tbl_cart(*, tbl_product(*)), tbl_user(user_name, user_contact)")
          .eq('booking_status', 5);

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

  Future<void> fetchartisan() async {
    try {
      final response =
          await supabase.from('tbl_artisan').count().eq('artisan_status', 1);
      setState(() {
        artisancount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchName() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select('artisan_name')
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .single()
          .limit(1);
      setState(() {
        artisanid = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 170,
              child: Card(
                child: Column(
                  children: [
                    Icon(
                      Icons.architecture,
                      color: const Color.fromARGB(255, 3, 1, 68),
                      size: 70,
                    ),
                    Text(
                      "Hello ",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 3, 1, 68),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      artisanid['artisan_name'] ?? "Artisan Name",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 3, 1, 68),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 170,
              child: Card(
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      color: const Color.fromARGB(255, 3, 1, 68),
                      size: 70,
                    ),
                    Text(
                      "Artisan",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 3, 1, 68),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      artisancount.toString(),
                      style: TextStyle(
                          color: const Color.fromARGB(255, 3, 1, 68),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: bookingData.isEmpty
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
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
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
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: cartData.map<Widget>((cartItem) {
                                return ListTile(
                                  leading: Image.network(
                                    cartItem['product_photo'] ?? "",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported,
                                            size: 50),
                                  ),
                                  title: Text(
                                    cartItem['product_name'] ?? "Product Name",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                        cartId:
                                                            cartItem['cart_id'],
                                                      ),
                                                    ));
                                              },
                                              child: Text("View Design",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)))
                                          : SizedBox()
                                    ],
                                  ),
                                  trailing: Text(
                                    " ₹${cartItem['total']}",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                          ? "Accepted"
                                          : bookingItems['booking_status'] >= 7
                                              ? "Completed"
                                              : "Unknown Status",
                                  style: TextStyle(
                                      fontSize: 15,
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
        ),
      ],
    ));
  }
}
