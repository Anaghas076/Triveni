import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class CountReport extends StatefulWidget {
  const CountReport({super.key});

  @override
  State<CountReport> createState() => _CountReportState();
}

class _CountReportState extends State<CountReport> {
  DateTime? startDate;
  DateTime? endDate;
  int productCount = 0;
  int totalAmount = 0;
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = false;

  // Select date function
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2020);
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Fetch bookings and cart items based on date range
  Future<void> getProductCount() async {
    try {
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select both start and end dates")),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final response = await supabase
          .from('tbl_booking')
          .select(
              "*, tbl_cart(*, tbl_product(*)), tbl_weaver(*), tbl_artisan(*)")
          .gte('created_at', startDate!.toIso8601String())
          .lte('created_at', endDate!.toIso8601String())
          .order('booking_id', ascending: false);

      // Calculate total amount and flatten cart items
      int tempTotalAmount = 0;
      List<Map<String, dynamic>> tempCartItems = [];

      for (var booking in response) {
        tempTotalAmount += (booking['booking_amount'] as int?) ?? 0;

        // Extract weaver and artisan names (or "N/A" if null)
        final weaverName = booking['tbl_weaver'] != null
            ? booking['tbl_weaver']['weaver_name']?.toString() ?? 'N/A'
            : 'N/A';
        final artisanName = booking['tbl_artisan'] != null
            ? booking['tbl_artisan']['artisan_name']?.toString() ?? 'N/A'
            : 'N/A';

        // Flatten tbl_cart list into cart items with additional booking-level info
        final cartList =
            List<Map<String, dynamic>>.from(booking['tbl_cart'] ?? []);
        for (var cartItem in cartList) {
          tempCartItems.add({
            ...cartItem,
            'weaver_name': weaverName,
            'artisan_name': artisanName,
          });
        }
      }

      setState(() {
        bookings = List<Map<String, dynamic>>.from(response);
        cartItems = tempCartItems;
        productCount = cartItems.length; // Count of cart items (products)
        totalAmount = tempTotalAmount;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching product count: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Report")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: startDate == null
                            ? ""
                            : "${startDate!.toLocal()}".split(' ')[0]),
                    decoration: const InputDecoration(
                      labelText: "Start Date",
                      hintText: "Select Start Date",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: endDate == null
                            ? ""
                            : "${endDate!.toLocal()}".split(' ')[0]),
                    decoration: const InputDecoration(
                      labelText: "End Date",
                      hintText: "Select End Date",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getProductCount,
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey), // Adds border
                borderRadius: BorderRadius.circular(10), // Rounded corners
                color: Colors.white, // Background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("SNo.")),
                    DataColumn(label: Text("Image")),
                    DataColumn(label: Text("Product")),
                    DataColumn(label: Text("Weaver")),
                    DataColumn(label: Text("Artisan")),
                    DataColumn(label: Text("Subcategory")),
                    DataColumn(label: Text("Code")),
                    DataColumn(label: Text("Price")),
                    DataColumn(label: Text("Quantity")),
                    DataColumn(label: Text("Type")),
                  ],
                  rows: List.generate(
                    cartItems.length,
                    (index) {
                      var cartItem = cartItems[index];
                      var product = cartItem['tbl_product'] ?? {};

                      return DataRow(
                        cells: [
                          DataCell(Text((index + 1).toString())),
                          DataCell(
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                product['product_photo']?.toString() ?? '',
                              ),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          DataCell(
                              Text(product['product_name']?.toString() ?? '')),
                          DataCell(Text(
                              cartItem['weaver_name']?.toString() ?? 'N/A')),
                          DataCell(Text(
                              cartItem['artisan_name']?.toString() ?? 'N/A')),
                          DataCell(Text(
                              product['subcategory_id']?.toString() ?? '')),
                          DataCell(
                              Text(product['product_code']?.toString() ?? '')),
                          DataCell(
                              Text(product['product_price']?.toString() ?? '')),
                          DataCell(Text(
                              cartItem['cart_quantity']?.toString() ?? '0')),
                          DataCell(
                              Text(product['product_type']?.toString() ?? '')),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Total Amount: ₹$totalAmount",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
