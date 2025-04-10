import 'package:admin_triveni/screen/custom.dart';

import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  _MybookingDataState createState() => _MybookingDataState();
}

class _MybookingDataState extends State<Booking> {
  List<Map<String, dynamic>> bookingData = [];
  int bookingid = 0;
  int paymentid = 0;
  Future<void> fetchBooking() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              "*, tbl_cart(*, tbl_product(*)), tbl_user(user_name, user_contact)")
          .gte('booking_status', 1)
          .order('booking_id', ascending: false);
      ; // Ensure only valid bookings are fetched

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
            //'customData': customData,
          });
        }

        orders.add({
          'booking_id': data['booking_id'],
          'created_at': data['created_at'],
          'booking_amount': data['booking_amount'],
          'booking_status': data['booking_status'],
          'payment_status': data['payment_status'],
          'user_name': data['tbl_user']['user_name'],
          'user_contact': data['tbl_user']['user_contact'],
          'cart': cartItems,
          'hasCustom': hasCustom,
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
      await supabase
          .from('tbl_booking')
          .update({'booking_status': status}).eq('booking_id', bookingId);

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

  TextEditingController amountController = TextEditingController();

  void submitAmount(int id) async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select('booking_amount')
          .eq('booking_id', id)
          .single();

      int currentAmount = response['booking_amount'] ?? 0;
      int newAmount = int.tryParse(amountController.text) ?? 0;

      if (newAmount > 0) {
        await supabase.from('tbl_booking').update(
            {'booking_amount': currentAmount + newAmount}).eq('booking_id', id);

        fetchBooking(); // Refresh the booking list
      }
    } catch (e) {
      print("Error updating booking amount: $e");
    }
  }

  // Future<void> pay(int bookingId, int paymentStatus) async {
  //   try {
  //     String amount = amountController.text;

  //     await Supabase.instance.client.from('tbl_daily').insert({
  //       'daily_name': "salary",
  //       'daily_amount': amount,
  //       'daily_type': "INCOME",
  //     });

  //     await Supabase.instance.client.from('tbl_booking').update(
  //         {'payment_status': paymentStatus}).eq('booking_id', bookingId);

  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text("Payment Processed Successfully"),
  //       backgroundColor: const Color.fromARGB(255, 54, 3, 116),
  //     ));
  //     amountController.clear();
  //     fetchBooking();
  //   } catch (e) {
  //     print("Error processing payment: $e");
  //   }
  // }

  void addAmount(int id) {
    amountController.clear(); // Clear previous input

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Change Amount"),
          content: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Enter Amount"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                submitAmount(id);
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Future<void> settleAmount(int id, String name) async {
    try {
      final response =
          await supabase.from('tbl_booking').select().maybeSingle().limit(1);
      await supabase.from('tbl_daily').insert({
        'daily_amount': amountController.text,
        name: response![name],
        'daily_type': "INCOME",
        'daily_name': "Salary",
      });
      int status = response['payment_status'];
      await supabase
          .from('tbl_booking')
          .update({'payment_status': status + 1}).eq('booking_id', id);
      fetchBooking();
    } catch (e) {
      print("Error settling: $e");
    }
  }

  void payAmount(int id, String name) {
    amountController.clear(); // Clear previous input

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pay Amount"),
          content: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Enter Amount"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                settleAmount(id, name);
                Navigator.pop(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
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
                  Text(
                    bookingItems['user_name'] ?? "User Name",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    bookingItems['user_contact'] ?? "User Contact",
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Date: ${bookingItems['created_at']}",
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
                            Text("Code: ${cartItem['product_code']}"),
                            Text("QTY: ${cartItem['cart_quantity']}"),
                            cartItem['isCustom']
                                ? ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Viewdesign(
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
                              fontWeight: FontWeight.bold, color: Colors.black),
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
                          if (bookingItems['booking_status'] == 1)
                            ElevatedButton(
                              onPressed: () {
                                order(bookingItems['booking_id'], 2);
                              },
                              child: Text(
                                "Publish To Weaver",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (bookingItems['booking_status'] == 4)
                            ElevatedButton(
                              onPressed: () {
                                order(bookingItems['booking_id'], 5);
                              },
                              child: Text(
                                "Publish to Artisan",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (bookingItems['booking_status'] == 7)
                            ElevatedButton(
                              onPressed: () {
                                order(bookingItems['booking_id'], 8);
                              },
                              child: Text(
                                "Item Packed",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (bookingItems['booking_status'] == 8)
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    order(bookingItems['booking_id'], 9);
                                  },
                                  child: Text(
                                    "Request for payment",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                if (bookingItems['hasCustom'])
                                  ElevatedButton(
                                      onPressed: () {
                                        addAmount(bookingItems['booking_id']);
                                      },
                                      child: Text("Change Amount"))
                              ],
                            ),
                          if (bookingItems['booking_status'] == 10)
                            ElevatedButton(
                              onPressed: () {
                                order(bookingItems['booking_id'], 11);
                              },
                              child: Text(
                                "Shipped",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (bookingItems['booking_status'] == 11)
                            ElevatedButton(
                              onPressed: () {
                                order(bookingItems['booking_id'], 12);
                              },
                              child: Text(
                                "Delivered",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (bookingItems['booking_status'] == 12 &&
                              bookingItems['payment_status'] == 0)
                            ElevatedButton(
                              onPressed: () {
                                // pay(bookingItems['booking_id'],
                                //     1); // Pay Weaver
                                payAmount(
                                    bookingItems['booking_id'], "weaver_id");
                              },
                              child: Text(
                                "Settle Weaver",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          else if (bookingItems['booking_status'] == 12 &&
                              bookingItems['payment_status'] == 1)
                            ElevatedButton(
                              onPressed: () {
                                payAmount(
                                    bookingItems['booking_id'], "artisan_id");
                                // Pay Artisan
                              },
                              child: Text(
                                "Settle Artisan",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            Container(),
                        ],
                      ),
                      Text(
                        bookingItems['booking_status'] == 12
                            ? (bookingItems['payment_status'] == 1
                                ? "Paid to Weaver"
                                : bookingItems['payment_status'] == 2
                                    ? "Payment complete"
                                    : "Delivered")
                            : bookingItems['booking_status'] == 1
                                ? "Ordered"
                                : bookingItems['booking_status'] == 2
                                    ? "Publish to Weaver"
                                    : bookingItems['booking_status'] == 3
                                        ? "Weaver Accepted"
                                        : bookingItems['booking_status'] == 4
                                            ? "Weaver Completed"
                                            : bookingItems['booking_status'] ==
                                                    5
                                                ? "Publish to Artisan"
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
                                                            ? "Item Packed"
                                                            : bookingItems[
                                                                        'booking_status'] ==
                                                                    9
                                                                ? "Request for Payment"
                                                                : bookingItems[
                                                                            'booking_status'] ==
                                                                        10
                                                                    ? "Paid"
                                                                    : bookingItems['booking_status'] ==
                                                                            11
                                                                        ? "Shipped"
                                                                        : "Unknown Status", // Default case
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
