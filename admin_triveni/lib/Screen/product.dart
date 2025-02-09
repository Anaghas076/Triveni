import 'package:admin_triveni/Screen/addproduct.dart';
import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  List<Map<String, dynamic>> products = [];

  Future<void> fetchproduct() async {
    try {
      final response =
          await supabase.from('tbl_product').select("*, tbl_subcategory(*)");
      setState(() {
        products = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_product').delete().eq('product_id', id);
      fetchproduct();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchproduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DataTable(
        columns: [
          DataColumn(label: Text("SNo.")),
          DataColumn(label: Text("Name")),
          // DataColumn(label: Text("Category")),
          DataColumn(label: Text("Subcategory")),
          DataColumn(label: Text("Price")),
          DataColumn(label: Text("Type")),
          DataColumn(label: Text("Description")),
        ],
        rows: List.generate(products.length, (index) {
          var data = products[index];
          return DataRow(cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(Text(data['product_name']?.toString() ?? '')),
            //  DataCell(
            // Text(data['tbl_category']?['category_name']?.toString() ?? '')),
            DataCell(Text(
                data['tbl_subcategory']?['subcategory_name']?.toString() ??
                    '')),
            DataCell(Text(data['product_price']?.toString() ?? '')),
            DataCell(Text(data['product_type']?.toString() ?? '')),
            DataCell(Text(data['product_description']?.toString() ?? '')),
          ]);
        }),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPrpduct(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      ),
    );
  }
}
