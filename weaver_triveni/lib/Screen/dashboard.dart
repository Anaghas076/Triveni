import 'package:flutter/material.dart';

import 'package:weaver_triveni/main.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  _OrdersDataState createState() => _OrdersDataState();
}

class _OrdersDataState extends State<Orders> {
  Map<String, dynamic> weaverid = {};
  int weavercount = 0;
  List<Map<String, dynamic>> bookingData = [];
  int bookingid = 0;
  double totalIncome = 0;
  double totalExpense = 0;
  int totalBookings = 0;
  List<Map<String, dynamic>> recentBookings = [];
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    fetchWeaver();
    fetchBooking();
    fetchName();
    fetchStats();
  }

  Future<void> showCustomImage(int cartId) async {
    try {
      final response = await supabase
          .from('tbl_customization')
          .select('customization_photo,customization_description')
          .eq('cart_id', cartId);

      if (response == null || response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No custom images found.')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              width: 350,
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    child: PhotoViewGallery.builder(
                      itemCount: response.length,
                      builder: (context, index) {
                        final imgUrl = response[index]['customization_photo'];
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(imgUrl),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        );
                      },
                      scrollPhysics: BouncingScrollPhysics(),
                      backgroundDecoration: BoxDecoration(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      response[0]['customization_description'] ?? '',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print("Error fetching custom image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading images')),
      );
    }
  }

  Future<void> fetchBooking() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              "*, tbl_cart(*, tbl_product(*)), tbl_user(user_name, user_contact, user_id)")
          .eq('booking_status', 2);

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
          'user_id': data['tbl_user']['user_id'],
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
      final weaverId = supabase.auth.currentUser!.id;
      await supabase.from('tbl_booking').update({
        'booking_status': status,
        'weaver_id': weaverId,
      }).eq('booking_id', bookingId);

      // Fetch the client's FCM token
      String? userToken;
      final booking =
          bookingData.firstWhere((b) => b['booking_id'] == bookingId);
      final userId = booking['user_id'];

      if (userId != null) {
        final response = await supabase
            .from('tbl_user')
            .select('fcm_token')
            .eq('id', userId)
            .single();

        userToken = response['fcm_token'] as String?;
      }

      // Send push notification to the client
      if (userToken != null) {
        setState(() {
          bookingid = bookingId; // Set bookingid for notification message
        });
      }

      fetchBooking();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchWeaver() async {
    try {
      final response =
          await supabase.from('tbl_weaver').count().eq('weaver_status', 1);
      setState(() {
        weavercount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  String formatDate(String timestamp) {
    DateTime parsedDate = DateTime.parse(timestamp);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  Future<void> fetchName() async {
    try {
      final response = await supabase
          .from('tbl_weaver')
          .select('weaver_name')
          .eq('weaver_id', supabase.auth.currentUser!.id)
          .single()
          .limit(1);
      setState(() {
        weaverid = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchStats() async {
    setState(() => isLoadingStats = true);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    try {
      // Fetch work data for income/expense
      final workResponse = await supabase
          .from('tbl_daily')
          .select()
          .eq('weaver_id', supabase.auth.currentUser!.id)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String());

      double income = 0, expense = 0;
      for (var t in workResponse) {
        final amt = double.tryParse(t['daily_amount'].toString()) ?? 0;
        if (t['daily_type'] == 'INCOME') {
          income += amt;
        } else {
          expense += amt;
        }
      }

      // Fetch bookings for the month
      final bookingResponse = await supabase
          .from('tbl_booking')
          .select('*, tbl_user(user_name)')
          .eq('weaver_id', supabase.auth.currentUser!.id)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String())
          .order('created_at', ascending: false);

      setState(() {
        totalIncome = income;
        totalExpense = expense;
        totalBookings = bookingResponse.length;
        recentBookings = bookingResponse.take(5).toList();
        isLoadingStats = false;
      });
    } catch (e) {
      setState(() => isLoadingStats = false);
    }
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('Income', totalIncome, Colors.green),
        _buildStatCard('Expense', totalExpense, Colors.red),
        _buildStatCard('Bookings', totalBookings.toDouble(), Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title == 'Bookings'
                      ? value.toInt().toString()
                      : '₹${value.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBookings() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            recentBookings.isEmpty
                ? Text('No bookings found for this month')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: recentBookings.length,
                    itemBuilder: (context, index) {
                      final booking = recentBookings[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                          child: Text(
                            booking['tbl_user']['user_name'][0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          booking['tbl_user']['user_name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          booking['created_at'] != null
                              ? booking['created_at']
                                  .toString()
                                  .substring(0, 10)
                              : '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          '₹${booking['booking_amount']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoadingStats
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(10),
              children: [
                _buildStatCards(),
                SizedBox(height: 16),
                _buildRecentBookings(),
                SizedBox(height: 16),
                Text(
                  "New Orders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                bookingData.isEmpty
                    ? Center(child: Text("No Orders"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
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
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Booking Details
                                      Text(
                                        bookingItems['user_name'] ??
                                            "User Name",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        bookingItems['user_contact'] ??
                                            "User Contact",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.green),
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.green),
                                      ),

                                      SizedBox(height: 10),

                                      // Cart Items List
                                      Column(
                                        children:
                                            cartData.map<Widget>((cartItem) {
                                          return ListTile(
                                            leading: Image.network(
                                              cartItem['product_photo'] ?? "",
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(
                                                      Icons.image_not_supported,
                                                      size: 50),
                                            ),
                                            title: Text(
                                              cartItem['product_name'] ??
                                                  "Product Name",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "Code: ${cartItem['product_code']}"),
                                                Text(
                                                    "QTY: ${cartItem['cart_quantity']}"),
                                                cartItem['isCustom']
                                                    ? ElevatedButton(
                                                        onPressed: () {
                                                          showCustomImage(
                                                              cartItem[
                                                                  'cart_id']);
                                                        },
                                                        child: Text(
                                                            "View Design",
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)))
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (bookingItems[
                                                      'booking_status'] ==
                                                  2)
                                                ElevatedButton(
                                                  onPressed: () {
                                                    order(
                                                        bookingItems[
                                                            'booking_id'],
                                                        3);
                                                  },
                                                  child: Text(
                                                    "Accept",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              if (bookingItems[
                                                      'booking_status'] ==
                                                  3)
                                                ElevatedButton(
                                                  onPressed: () {
                                                    order(
                                                        bookingItems[
                                                            'booking_id'],
                                                        4);
                                                  },
                                                  child: Text(
                                                    "Complete",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            bookingItems['booking_status'] == 2
                                                ? "New Order"
                                                : bookingItems[
                                                            'booking_status'] ==
                                                        3
                                                    ? " Accepted"
                                                    : bookingItems[
                                                                'booking_status'] >=
                                                            4
                                                        ? " Completed"
                                                        : "Unknown Status",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }
}
