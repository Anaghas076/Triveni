import 'package:admin_triveni/screen/custom.dart';
import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  _MybookingDataState createState() => _MybookingDataState();
}

class _MybookingDataState extends State<Booking> {
  List<Map<String, dynamic>> bookingData = [];
  int bookingid = 0;
  int paymentid = 0;
  late Map<String, dynamic> _serviceAccountConfig;

  @override
  void initState() {
    super.initState();
    _loadServiceAccountConfig(); // Load config once during initialization
    fetchBooking();
  }

  Future<void> _loadServiceAccountConfig() async {
    _serviceAccountConfig = await loadConfig();
  }

  Future<Map<String, dynamic>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('asset/config.json');
      print("Config Loaded: $jsonString");
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print("Error loading config.json: $e");
      return {};
    }
  }

  Future<String> getAccessToken() async {
    const List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountConfig),
      scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountConfig),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  Future<void> sendPushNotification(
      String title, String subtitle, String userToken) async {
    try {
      final String serverKey = await getAccessToken();
      const String projectId = "kerala-traditional-wear"; // Update this!
      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': userToken,
          'notification': {
            'title': title,
            'body': subtitle,
          },
          'data': {
            'current_user_fcm_token': userToken,
          },
        }
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully');
      } else {
        print(
            'Failed to send FCM message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Failed Notification: $e");
    }
  }

  Future<void> multiNotification(
      List<String> userTokens, String title, String subtitle) async {
    try {
      final String serverKey = await getAccessToken();
      const String projectId = "kerala-traditional-wear"; // Update this!
      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // Iterate through each user token
      for (String userToken in userTokens) {
        final Map<String, dynamic> message = {
          'message': {
            'token': userToken,
            'notification': {
              'title': title,
              'body': subtitle,
            },
            'data': {
              'current_user_fcm_token': userToken,
            },
          }
        };

        final response = await http.post(
          Uri.parse(fcmEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverKey',
          },
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          print('FCM message sent successfully to $userToken');
        } else {
          print(
              'Failed to send FCM message to $userToken: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print("Failed Notification: $e");
    }
  }

  Future<void> fetchBooking() async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select(
              "*, tbl_cart(*, tbl_product(*)), tbl_user(user_name, user_contact)")
          .gte('booking_status', 1)
          .order('booking_id', ascending: false);

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
          'payment_status': data['payment_status'],
          'user_name': data['tbl_user']['user_name'],
          'user_contact': data['tbl_user']['user_contact'],
          'weaver_id': data['weaver_id'],
          'artisan_id': data['artisan_id'],
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
      final user = await supabase
          .from('tbl_booking')
          .select('fcm_token')
          .eq('booking_id', bookingId)
          .single();
      // Only process FCM notification if recipientType is provided
      if (status == 2) {
        await weaverNotificatin();
      } else if (status == 5) {
        await artisanNotificatin();
      } else if (status == 9) {
        sendPushNotification(
            "Item Packed", "Complete Payment!", user['fcm_token']);
      } else if (status == 11) {
        sendPushNotification(
            "Item Shipped", "Item is out for delivery!", user['fcm_token']);
      } else if (status == 12) {
        sendPushNotification("Item Delivered", "Item Delivered Successfully!",
            user['fcm_token']);
      }

      fetchBooking();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> weaverNotificatin() async {
    try {
      final response = await supabase
          .from('tbl_weaver')
          .select('fcm_token')
          .eq('weaver_id', supabase.auth.currentUser!.id)
          .eq('weaver_status', 1);
      List<String> weaver = [];
      for (var data in response) {
        weaver.add(data['fcm_token']);
      }
      multiNotification(weaver, "New Work Assignment",
          "New Work Assignment Available. Check it out!");
    } catch (e) {
      print("Error fetcing weaver: $e");
    }
  }

  Future<void> artisanNotificatin() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select('fcm_token')
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .eq('artisan_status', 1);
      List<String> artisan = [];
      for (var data in response) {
        artisan.add(data['fcm_token']);
      }
      multiNotification(artisan, "New Work Assignment",
          "New Work Assignment Available. Check it out!");
    } catch (e) {
      print("Error fetcing artisan: $e");
    }
  }

  void userNotification(String title, String subtitle, String userId) {
    try {} catch (e) {
      print("Error fetching user: $e");
    }
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
      final response = await supabase
          .from('tbl_booking')
          .select()
          .eq('booking_id', id)
          .maybeSingle()
          .limit(1);
      if (response == null) {
        print("Booking not found");
        return;
      }

      int bookingAmount = response['booking_amount'] ?? 0;
      int paidStatus = response['payment_status'] ?? 0;

      // Calculate already settled amount
      int alreadySettled = 0;
      if (paidStatus == 1 && name == "artisan_id") {
        // If weaver already settled, get weaver amount from tbl_daily
        final weaverDaily = await supabase
            .from('tbl_daily')
            .select('daily_amount')
            .eq('daily_name', 'Salary')
            .eq('weaver_id', response['weaver_id'])
            .maybeSingle();
        alreadySettled =
            int.tryParse(weaverDaily?['daily_amount']?.toString() ?? "0") ?? 0;
      }

      int enteredAmount = int.tryParse(amountController.text) ?? 0;
      int totalSettled = alreadySettled + enteredAmount;

      if (enteredAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enter a valid amount.")),
        );
        return;
      }

      if (totalSettled > bookingAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Amount exceeds booking amount!")),
        );
        return;
      }

      await supabase.from('tbl_daily').insert({
        'daily_amount': enteredAmount,
        name: response[name],
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

  void payAmount(int id, String name) async {
    amountController.clear(); // Clear previous input
    final formKey = GlobalKey<FormState>();
    int bookingAmount = 0;
    int alreadySettled = 0;

    // Fetch bookingAmount and alreadySettled before showing dialog
    try {
      final response = await supabase
          .from('tbl_booking')
          .select()
          .eq('booking_id', id)
          .maybeSingle()
          .limit(1);
      if (response != null) {
        bookingAmount = response['booking_amount'] ?? 0;
        int paidStatus = response['payment_status'] ?? 0;
        if (paidStatus == 1 && name == "artisan_id") {
          final weaverDaily = await supabase
              .from('tbl_daily')
              .select('daily_amount')
              .eq('daily_name', 'Salary')
              .eq('weaver_id', response['weaver_id'])
              .maybeSingle();
          alreadySettled =
              int.tryParse(weaverDaily?['daily_amount']?.toString() ?? "0") ??
                  0;
        }
      }
    } catch (e) {
      print("Error fetching booking for validation: $e");
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pay Amount"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Amount"),
              validator: (value) {
                int entered = int.tryParse(value ?? "") ?? 0;
                if (entered <= 0) {
                  return "Enter a valid amount.";
                }
                if ((alreadySettled + entered) > bookingAmount) {
                  return "Amount exceeds booking amount!";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  settleAmount(id, name);
                  Navigator.pop(context);
                }
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
      appBar: AppBar(
        title: Text("Booking List"),
        backgroundColor: Colors.blue,
      ),
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
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    bookingItems['user_contact'] ?? "User Contact",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Date: ${bookingItems['created_at']}",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Total Amount: ₹${bookingItems['booking_amount']}",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
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
