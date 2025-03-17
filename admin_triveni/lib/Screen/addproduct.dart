// import 'dart:io';
// import 'dart:typed_data';
import 'dart:io';
import 'dart:typed_data';

import 'package:admin_triveni/Components/formvalidation.dart';
import 'package:admin_triveni/Screen/pattribute.dart';
import 'package:admin_triveni/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];

  String? selectedCat;
  String? selectedSub;

  PlatformFile? pickedImage;

  // Handle File Upload Process
  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String name) async {
    try {
      final bucketName = 'product'; // Replace with your bucket name
      final filePath = "$name-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> submit() async {
    try {
      String name = nameController.text;
      String code = codeController.text;
      String price = priceController.text;
      // String type = typeController.text;
      String description = descriptionController.text;
      String? url = await photoUpload(name);

      print(name);
      print(code);
      print(price);
      print(selectedType);
      print(description);

      await supabase.from('tbl_product').insert({
        'product_name': name,
        'product_code': code,
        'product_price': price,
        'product_type': selectedType,
        'product_photo': url,
        'product_description': description,
        'subcategory_id': selectedSub,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ));
      nameController.clear();
      codeController.clear();
      priceController.clear();
      typeController.clear();
      descriptionController.clear();
      fetchproduct();
      setState(() {
        selectedCat = null;
        selectedSub = null;
      });
    } catch (e) {
      print("Error Product: $e");
    }
  }

  int eid = 0;
  String selectedType = '';

  Future<void> update() async {
    try {
      String? url = await photoUpload(nameController.text);
      await supabase.from('tbl_product').update({
        'product_name': nameController.text,
        'product_code': codeController.text,
        'product_price': priceController.text,
        'product_type': selectedType,
        'product_description': descriptionController.text,
        'product_photo': url,
        'subcategory_id': selectedSub,
      }).eq('product_id', eid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ));
      fetchproduct();
      nameController.clear();
      codeController.clear();
      priceController.clear();
      typeController.clear();
      descriptionController.clear();
      setState(() {
        eid = 0;
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_product').delete().eq('product_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ));
      fetchproduct();
    } catch (e) {}
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

  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: formkey,
              child: Container(
                width: 100,
                height: 300,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 FIRST COLUMN: Image Picker + Description Field
                            Expanded(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: handleImagePick,
                                    child: Container(
                                      height: 50,
                                      width: 100,
                                      child: pickedImage == null
                                          ? Icon(Icons.add_a_photo,
                                              size: 50,
                                              color:
                                                  Color.fromARGB(255, 3, 1, 68))
                                          : Image.memory(Uint8List.fromList(
                                              pickedImage!.bytes!)),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextFormField(
                                    validator: (value) =>
                                        FormValidation.validateDescription(
                                            value),
                                    style: TextStyle(color: Colors.white),
                                    controller: descriptionController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "Enter Product Description",
                                      hintStyle:
                                          TextStyle(color: Colors.yellowAccent),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Color.fromARGB(255, 3, 1, 68),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 20),

                            /// 🔹 SECOND COLUMN: Category + Subcategory + Type Selection
                            Expanded(
                              child: Column(
                                children: [
                                  DropdownButtonFormField(
                                    validator: (value) =>
                                        FormValidation.validateDropdown(value),
                                    style: TextStyle(color: Colors.white),
                                    dropdownColor: Colors.green,
                                    decoration: InputDecoration(
                                      fillColor:
                                          const Color.fromARGB(255, 3, 1, 68),
                                      filled: true,
                                      labelText: "Select category",
                                      labelStyle:
                                          TextStyle(color: Colors.yellowAccent),
                                    ),
                                    value: selectedCat,
                                    items: categories.map((cat) {
                                      return DropdownMenuItem(
                                        value: cat['category_id'].toString(),
                                        child: Text(cat['category_name'],
                                            style:
                                                TextStyle(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      fetchsubcategory(value!);
                                      setState(() {
                                        selectedCat = value;
                                      });
                                    },
                                  ),

                                  SizedBox(height: 10),

                                  DropdownButtonFormField(
                                    validator: (value) =>
                                        FormValidation.validateDropdown(value),
                                    style: TextStyle(color: Colors.white),
                                    dropdownColor: Colors.greenAccent,
                                    decoration: InputDecoration(
                                      fillColor:
                                          const Color.fromARGB(255, 3, 1, 68),
                                      filled: true,
                                      labelText: "Select Subcategory",
                                      labelStyle:
                                          TextStyle(color: Colors.yellowAccent),
                                    ),
                                    value: selectedSub,
                                    items: subcategories.map((sub) {
                                      return DropdownMenuItem(
                                        value: sub['subcategory_id'].toString(),
                                        child: Text(sub['subcategory_name'],
                                            style:
                                                TextStyle(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSub = value;
                                      });
                                    },
                                  ),

                                  SizedBox(height: 10),

                                  /// Type Selection
                                  Container(
                                    width: 500,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 3, 1, 68),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 3, 1, 68),
                                          width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Row(
                                          children: [
                                            Radio(
                                              activeColor: Colors.white,
                                              fillColor: WidgetStatePropertyAll(
                                                  Colors.grey),
                                              value: "Predesigned",
                                              groupValue: selectedType,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedType =
                                                      value.toString();
                                                });
                                              },
                                            ),
                                            Text("Predesigned",
                                                style: TextStyle(
                                                    color: Colors.yellowAccent,
                                                    fontSize: 17)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Radio(
                                              activeColor: Colors.white,
                                              fillColor: WidgetStatePropertyAll(
                                                  Colors.grey),
                                              value: "Customizable",
                                              groupValue: selectedType,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedType =
                                                      value.toString();
                                                });
                                              },
                                            ),
                                            Text("Customizable",
                                                style: TextStyle(
                                                    color: Colors.yellowAccent,
                                                    fontSize: 17)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 20),

                            /// 🔹 THIRD COLUMN: Name + Code + Price
                            Expanded(
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator: (value) =>
                                        FormValidation.validateName(value),
                                    style: TextStyle(color: Colors.white),
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Product Name",
                                      hintStyle:
                                          TextStyle(color: Colors.yellowAccent),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Color.fromARGB(255, 3, 1, 68),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    style: TextStyle(color: Colors.white),
                                    controller: codeController,
                                    decoration: InputDecoration(
                                      hintText: "Enter Product Code",
                                      hintStyle:
                                          TextStyle(color: Colors.yellowAccent),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Color.fromARGB(255, 3, 1, 68),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    validator: (value) =>
                                        FormValidation.validatePrice(value),
                                    style: TextStyle(color: Colors.white),
                                    controller: priceController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "Enter Product Price",
                                      hintStyle:
                                          TextStyle(color: Colors.yellowAccent),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Color.fromARGB(255, 3, 1, 68),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        /// 🔹 Submit Button (Fixed)

                        SizedBox(
                          width: 1700,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              if (formkey.currentState!.validate()) {
                                submit();
                              }
                            },
                            child: Text("Submit"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text("SNo.")),
                  DataColumn(label: Text("Image")),
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Subcategory")),
                  DataColumn(label: Text("Price")),
                  DataColumn(label: Text("Type")),
                  DataColumn(label: Text("Description")),
                  DataColumn(label: Text("Action")),
                ],
                rows: List.generate(
                  products.length,
                  (index) {
                    var data = products[index];
                    return DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(
                          CircleAvatar(
                              backgroundImage: NetworkImage(
                                  data['product_photo']?.toString() ?? '')),
                        ),
                        DataCell(Text(data['product_name']?.toString() ?? '')),
                        DataCell(Text(data['tbl_subcategory']
                                    ?['subcategory_name']
                                ?.toString() ??
                            '')),
                        DataCell(Text(data['product_price']?.toString() ?? '')),
                        DataCell(Text(data['product_type']?.toString() ?? '')),
                        DataCell(Text(
                            data['product_description']?.toString() ?? '')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  delete(data['product_id']);
                                },
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Pattribute(
                                          productid: data['product_id'],
                                        ),
                                      ));
                                },
                                icon: Icon(Icons.add),
                                color: const Color.fromARGB(255, 25, 4, 88),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
