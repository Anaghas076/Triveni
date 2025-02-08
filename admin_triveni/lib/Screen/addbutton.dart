import 'dart:io';
import 'dart:typed_data';
import 'package:admin_triveni/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class Addbutton extends StatefulWidget {
  const Addbutton({super.key});

  @override
  State<Addbutton> createState() => _AddbuttonState();
}

class _AddbuttonState extends State<Addbutton> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
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
      String description = descriptionController.text;
      String? url = await photoUpload(name);

      print(name);
      print(code);
      print(price);
      print(description);

      await supabase.from('tbl_product').insert({
        'product_name': name,
        'product_code': code,
        'product_price': price,
        'product_photo': url,
        'product_description': description,
        'subcategory_id': selectedSub,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      nameController.clear();
      codeController.clear();
      priceController.clear();
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

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_product').delete().eq('product_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Center(
              //pickimage code start...
              child: SizedBox(
                height: 100,
                width: 100,
                child: pickedImage == null
                    ? GestureDetector(
                        onTap: handleImagePick,
                        child: Icon(
                          Icons.add_a_photo,
                          color: Color.fromARGB(255, 19, 1, 83),
                          size: 50,
                        ),
                      )
                    : GestureDetector(
                        onTap: handleImagePick,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: pickedImage!.bytes != null
                              ? Image.memory(
                                  Uint8List.fromList(
                                      pickedImage!.bytes!), // For web
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(
                                      pickedImage!.path!), // For mobile/desktop
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
              ),
            ), //pickimage code ending
            SizedBox(
              height: 30,
            ),
            DropdownButtonFormField(
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.green,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(255, 54, 3, 116),
                  filled: true,
                  labelText: "Select category",
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
                dropdownColor: Colors.greenAccent,
                decoration: InputDecoration(
                    fillColor: const Color.fromARGB(255, 54, 3, 116),
                    filled: true,
                    labelText: "Select Subcategory",
                    labelStyle: TextStyle(color: Colors.yellowAccent)),
                value: selectedSub,
                items: subcategories.map((sub) {
                  return DropdownMenuItem(
                    child: Text(
                      sub['subcategory_name'],
                      style: TextStyle(),
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
                  hintText: "Enter Product Code",
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
                  hintText: "Enter Product Price",
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
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  hintText: "Enter Product Description",
                  hintStyle:
                      TextStyle(color: const Color.fromARGB(255, 248, 240, 10)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 54, 3, 116)),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      submit();
                    },
                    child: Text("Submit")),
              ],
            ),
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
                  title: Text(data['product_name'] ?? ''),
                  subtitle: Text(data['tbl_subcategory']['subcategory_name']),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            delete(data['product_id']);
                          },
                          icon: Icon(Icons.delete),
                          color: const Color.fromARGB(255, 250, 34, 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
