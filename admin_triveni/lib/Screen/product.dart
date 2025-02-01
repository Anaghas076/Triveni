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

  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];

  String? selectedCat;
  String? selectedSub;

  Future<void> submit() async {
   
    try {

      String name = nameController.text;
      String code = codeController.text;
      String price = priceController.text;
      String description = descriptionController.text;

      print(name);
      print(code);
      print(price);
      print(description);

      await supabase.from('tbl_product').insert({
       
        'category_id': selectedCat,
        'subcategory_id': selectedSub,
        'product_name': name,
        'product_code': code,
        'product_price': price,
        'product_description': description,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));

      
 nameController.clear();
 codeController.clear();
 priceController.clear();
 descriptionController.clear();

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchproduct();
  }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            child: ListView(
      padding: EdgeInsets.all(20),
      children: [
        DropdownButtonFormField(
            style: TextStyle(color: Colors.white),
            dropdownColor: Colors.green,
            decoration: InputDecoration(
              fillColor: const Color.fromARGB(255, 54, 3, 116),
              filled: true,
              labelText: "Select Category",
              labelStyle: TextStyle(color: Colors.yellowAccent),
            ),
            value: selectedCat,
            items: categories.map((cat) {
              return DropdownMenuItem(
                child: Text(
                  cat['category_name'],
                  style: TextStyle(),
                ),
                value: cat['category_id'].toString(),
              );
            }).toList(),
            onChanged: (value) {
              fetchsubcategory(value!);
              setState(() {
                selectedCat = value;
              });
            }),
        SizedBox(
          height: 20,
        ),
        DropdownButtonFormField(
            style: TextStyle(color: Colors.white),
            dropdownColor: Colors.green,
            decoration: InputDecoration(
                fillColor: const Color.fromARGB(255, 54, 3, 116),
                filled: true,
                labelText: "Select subcategory",
                labelStyle: TextStyle(color: Colors.yellowAccent)),
            value: selectedSub,
            items: subcategories.map((sub) {
              return DropdownMenuItem(
                child: Text(
                  sub['subcategory_name'],
                ),
                value: sub['subcategory_id'].toString(),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSub = value;
              });
            }),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: nameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
              hintText: "Enter Product Name",
              hintStyle:
                  TextStyle(color: const Color.fromARGB(255, 248, 240, 10)),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: const Color.fromARGB(255, 54, 3, 116)),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: codeController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
              hintText: "Enter  Product Code",
              hintStyle:
                  TextStyle(color: const Color.fromARGB(255, 248, 240, 10)),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: const Color.fromARGB(255, 54, 3, 116)),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              hintText: "Enter  Product price",
              hintStyle:
                  TextStyle(color: const Color.fromARGB(255, 248, 240, 10)),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: const Color.fromARGB(255, 54, 3, 116)),
        ),
        SizedBox(
          height: 20,
        ),
        TextFormField(
          style: TextStyle(color: Colors.white),
          controller: descriptionController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
              hintText: "Enter  Product Description",
              hintStyle:
                  TextStyle(color: const Color.fromARGB(255, 248, 240, 10)),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: const Color.fromARGB(255, 54, 3, 116)),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
            onPressed: () {
              submit();
            },
            child: Text("Submit")),
        SizedBox(
          height: 50,
        ),
       ListView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final data = products[index];
            return ListTile(
              leading: Text((index + 1).toString()),
              title: Text(data['product_name']),
              trailing: IconButton(
                  onPressed: () {
                    delete(data['product_id']);
                  },
                  icon: Icon(Icons.delete,
                      color: const Color.fromARGB(255, 255, 21, 0))),
            );
          },
        )
      ],
    )));
  }
}