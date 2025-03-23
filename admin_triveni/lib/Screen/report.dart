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
  int totalProducts = 0;
  int totalAmount = 0;
  List<Map<String, dynamic>> soldProducts = [];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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

  Future<void> getProductReport() async {
    try {
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select both start and end dates")),
        );
        return;
      }

      final response = await supabase
          .from('tbl_booking')
          .select("""
          *,
          tbl_cart(*, 
            tbl_product(*, 
              tbl_subcategory(*, 
                tbl_category(*)
              )
            )
          )
        """)
          .gte('created_at', startDate!.toIso8601String())
          .lte('created_at', endDate!.toIso8601String())
          .order('booking_id', ascending: false);

      int totalAmountCalc = 0;
      int totalProductCount = 0;
      List<Map<String, dynamic>> extractedProducts = [];

      for (var booking in response) {
        var cartItems = booking['tbl_cart'] ?? [];

        for (var cartItem in cartItems) {
          var product = cartItem['tbl_product'] ?? {};
          var subcategory = product['tbl_subcategory'] ?? {};
          var category = subcategory['tbl_category'] ?? {};
          int quantity = cartItem['quantity'] ?? 0;
          int price =
              int.tryParse(product['product_price']?.toString() ?? '0') ?? 0;

          totalProductCount += quantity;
          totalAmountCalc += (quantity * price);

          extractedProducts.add({
            'product_name': product['product_name'],
            'product_photo': product['product_photo'],
            'category_name': category['category_name'],
            'subcategory_name': subcategory['subcategory_name'],
            'product_code': product['product_code'],
            'product_price': product['product_price'],
            'quantity': quantity,
            'product_type': product['product_type'],
          });
        }
      }

      setState(() {
        soldProducts = extractedProducts;
        totalProducts = totalProductCount;
        totalAmount = totalAmountCalc;
      });
    } catch (e) {
      print("Error fetching product report: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Sales Report")),
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
              onPressed: getProductReport,
              child: const Text("Generate Report"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12,
                  horizontalMargin: 10,
                  columns: const [
                    DataColumn(label: Text("SNo.")),
                    DataColumn(label: Text("Image")),
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Category")),
                    DataColumn(label: Text("Subcategory")),
                    DataColumn(label: Text("Code")),
                    DataColumn(label: Text("Price")),
                    DataColumn(label: Text("Quantity")),
                    DataColumn(label: Text("Type")),
                  ],
                  rows: List.generate(
                    soldProducts.length,
                    (index) {
                      var data = soldProducts[index];

                      return DataRow(
                        cells: [
                          DataCell(
                              Text((index + 1).toString())), // Serial Number
                          DataCell(
                            CircleAvatar(
                              backgroundImage: data['product_photo'] != null
                                  ? NetworkImage(
                                      data['product_photo'].toString())
                                  : const AssetImage(
                                          'assets/images/placeholder.png')
                                      as ImageProvider,
                            ),
                          ),
                          DataCell(
                              Text(data['product_name']?.toString() ?? 'N/A')),
                          DataCell(Text(data['category_name']?.toString() ??
                              'N/A')), // ✅ Category Name
                          DataCell(Text(data['subcategory_name']?.toString() ??
                              'N/A')), // ✅ Subcategory Name
                          DataCell(
                              Text(data['product_code']?.toString() ?? 'N/A')),
                          DataCell(Text(
                              "₹${data['product_price']?.toString() ?? '0'}")),
                          DataCell(Text(data['quantity']
                              .toString())), // ✅ Quantity Display Fixed
                          DataCell(
                              Text(data['product_type']?.toString() ?? 'N/A')),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Total Products Sold: $totalProducts",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
