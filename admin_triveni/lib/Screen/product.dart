import 'package:admin_triveni/Screen/addbutton.dart';
import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];

  String? selectedCat;
  String? selectedSub;

  Future<void> Add() async {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Addbutton(),
          ));
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchproduct() async {
    try {
      final response =
          await supabase.from('tbl_product').select(" * ,tbl_subcategory(*)");
      setState(() {
        products = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchsubcategory(String id) async {
    try {
      print("Subcategory");
      final response =
          await supabase.from('tbl_subcategory').select().eq('category_id', id);
      setState(() {
        subcategories = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchcategory() async {
    try {
      print("Category");
      final response = await supabase.from('tbl_category').select();
      print(response);
      setState(() {
        categories = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchcategory();
    //fetchsubcategory(String id);
    fetchproduct();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ListView.builder(
            itemCount: products.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final data = products[index];
              return ListTile(
                leading: Text((index + 1).toString()),
                title: Text(data['product_name'] ?? ''),
                subtitle: Text(data['tbl_subcategory']['subcategory_name']),
                trailing: SizedBox(
                  width: 80,
                ),
              );
            },
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              Add();
            },
            child: Text(
              "ADD BUTTON",
              style: const TextStyle(
                color: Color.fromARGB(255, 10, 1, 53),
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
