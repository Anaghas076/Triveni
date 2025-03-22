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
  List<Map<String, dynamic>> products = [];

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

  // Fetch products based on date range
  Future<void> getProductCount() async {
    try {
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select both start and end dates")),
        );
        return;
      }
      final response = await supabase
          .from('tbl_booking') // Start from tbl_booking
          .select("""
        *, 
        tbl_cart(*, 
            tbl_product(*, 
                tbl_subcategory(subcategory_name)
            )
        )
    """) // Fetch from tbl_cart, including product and subcategory details
          .gte('created_at', startDate!.toIso8601String())
          .lte('created_at', endDate!.toIso8601String())
          .order('booking_id', ascending: false); // Order by booking ID

      setState(() {
        products = List<Map<String, dynamic>>.from(response);
        productCount = products.length;
      });
    } catch (e) {
      print("Error fetching product count: $e");
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
                    decoration: InputDecoration(
                      labelText: "Start Date",
                      hintText: "Select Start Date",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                        text: endDate == null
                            ? ""
                            : "${endDate!.toLocal()}".split(' ')[0]),
                    decoration: InputDecoration(
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
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FittedBox(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("SNo.")),
                      DataColumn(label: Text("Image")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Subcategory")),
                      DataColumn(label: Text("Code")),
                      DataColumn(label: Text("Price")),
                      DataColumn(
                          label: Text("Quantity")), // Added Quantity Column
                      DataColumn(label: Text("Type")),
                    ],
                    rows: List.generate(
                      products.length,
                      (index) {
                        var data = products[index];
                        var product = data['tbl_product'] ?? {};
                        var subcategory = product['tbl_subcategory'] ?? {};

                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  product['product_photo']?.toString() ?? '',
                                ),
                              ),
                            ),
                            DataCell(Text(
                                product['product_name']?.toString() ?? '')),
                            DataCell(Text(
                                subcategory['subcategory_name']?.toString() ??
                                    '')), // Corrected Subcategory
                            DataCell(Text(
                                product['product_code']?.toString() ?? '')),
                            DataCell(Text(
                                product['product_price']?.toString() ?? '')),
                            DataCell(Text(data['quantity']?.toString() ??
                                '0')), // Display Quantity
                            DataCell(Text(
                                product['product_type']?.toString() ?? '')),
                          ],
                        );
                      },
                    ),
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
