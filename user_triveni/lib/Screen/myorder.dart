import 'dart:io';

import 'package:flutter/material.dart';
import 'package:user_triveni/screen/payment.dart';
import 'package:user_triveni/screen/postcomplaint.dart';
import 'package:user_triveni/screen/rating.dart';
import 'package:user_triveni/main.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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
            'product_size': cartData['product_size'],
            'product_price': cartData['tbl_product']['product_price'],
            'product_code': cartData['tbl_product']['product_code'],
            'total': total,
          });
        }

        orders.add({
          'booking_id': data['booking_id'],
          'booking_status': data['booking_status'],
          'booking_amount': data['booking_amount'],
          'created_at': data['created_at'],
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

  Future<void> order(int bookingId, int status, int amount) async {
    try {
      await supabase
          .from('tbl_booking')
          .update({'booking_status': status}).eq('booking_id', bookingId);
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
    DateTime parsedDate = DateTime.parse(timestamp);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  // Generate and preview PDF bill
  Future<void> generateBill(Map<String, dynamic> booking) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Order Bill',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Booking ID: ${booking['booking_id']}'),
                pw.Text('Date: ${formatDate(booking['created_at'])}'),
                pw.Text('Total Amount: Rs.${booking['booking_amount']}'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Items:',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: [
                    'Product Name',
                    'Code',
                    'Size',
                    'Qty',
                    'Price',
                    'Total'
                  ],
                  data: (booking['cart'] as List<Map<String, dynamic>>)
                      .map((item) {
                    return [
                      item['product_name'],
                      item['product_code'],
                      item['product_size'].toString(),
                      item['cart_quantity'].toString(),
                      'Rs.${item['product_price']}',
                      'Rs.${item['total']}',
                    ];
                  }).toList(),
                  border: null,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: pw.EdgeInsets.all(5),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Status: ${getStatusText(booking['booking_status'])}',
                  style: pw.TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      );

      final directory = await getExternalStorageDirectory();
      final file =
          File("${directory!.path}/Order_${booking['booking_id']}_Bill.pdf");
      await file.writeAsBytes(await pdf.save());

      // Open the PDF file
      OpenFile.open(file.path);
    } catch (e) {
      print("Error PDF: $e");
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return "Ordered";
      case 2:
        return "Published to Weaver";
      case 3:
        return "Weaver Accepted";
      case 4:
        return "Weaver Completed";
      case 5:
        return "Published to Artisan";
      case 6:
        return "Artisan Accepted";
      case 7:
        return "Artisan Completed";
      case 8:
        return "Item Packed";
      case 9:
        return "Awaiting Payment";
      case 10:
        return "Paid";
      case 11:
        return "Shipped";
      case 12:
        return "Delivered";
      default:
        return "Unknown";
    }
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
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: cartData.map<Widget>((cartItem) {
                            return Column(
                              children: [
                                ListTile(
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
                                      Text(
                                          "Code: ${cartItem['product_code'] ?? 'N/A'}"),
                                      Text("Size: ${cartItem['product_size']}"),
                                      Text("QTY: ${cartItem['cart_quantity']}"),
                                    ],
                                  ),
                                  trailing: Column(
                                    children: [
                                      Text(
                                        "Rs.${cartItem['total']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      SizedBox(height: 10),
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
                                ),
                                if (bookingItems['booking_status'] == 12)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Rating(
                                              pid: cartItem['product_id']),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Rate",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
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
                                  order(bookingItems['booking_id'], 10,
                                      bookingItems['booking_amount']);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PaymentGatewayScreen(
                                        amt: bookingItems['booking_amount'],
                                        id: bookingItems['booking_id'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Pay Amount",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            SizedBox(width: 5),
                            Text(
                              getStatusText(bookingItems['booking_status']),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 5),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        bookingItems['booking_status'] == 12
                            ? ElevatedButton(
                                onPressed: () {
                                  generateBill(bookingItems);
                                },
                                child: Text(
                                  "Generate Bill",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
