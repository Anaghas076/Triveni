import 'dart:io';
import 'dart:typed_data';

import 'package:admin_triveni/Components/formvalidation.dart';
import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final TextEditingController categoryController = TextEditingController();
  List<Map<String, dynamic>> categories = [];

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
      final bucketName = 'category'; // Replace with your bucket name
      final filePath = "$name-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> submit() async {
    try {
      if (pickedImage == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Pick an image first')));
      } else {
        String category = categoryController.text;
        String? url = await photoUpload(category);
        await supabase.from('tbl_category').insert({
          'category_name': category,
          'category_photo': url,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Inserted"),
          backgroundColor: const Color.fromARGB(255, 54, 3, 116),
        ));
        categoryController.clear();
        setState(() {
          pickedImage = null;
        });
        fetchCategory();
      }
    } catch (e) {
      print("Error Category: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_category').delete().eq('category_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchCategory();
    } catch (e) {
      print("Error: $e");
    }
  }

  int eid = 0;
  String imageUrl = "";

  Future<void> update() async {
    try {
      String? url = await photoUpload(categoryController.text);
      await supabase.from('tbl_category').update({
        'category_name': categoryController.text,
        'category_photo': url,
      }).eq('category_id', eid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchCategory();
      categoryController.clear();
      setState(() {
        eid = 0;
        pickedImage = null; // Reset the image when updating
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> fetchCategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categories = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Center(
              child: SizedBox(
                  height: 100,
                  width: 100,
                  child: pickedImage == null && imageUrl == ""
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
                            child: pickedImage != null
                                ? Image.memory(
                                    Uint8List.fromList(pickedImage!.bytes!),
                                    fit: BoxFit.cover,
                                  )
                                : (imageUrl != ""
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : SizedBox.shrink()),
                          ),
                        )),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              validator: (value) => FormValidation.validateCategory(value),
              style: TextStyle(color: Colors.white),
              controller: categoryController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  hintText: "Enter Category Name",
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
                  if (formkey.currentState!.validate()) {
                    if (eid == 0) {
                      submit();
                    } else {
                      update();
                    }
                  }
                },
                child: Text("Submit")),
            SizedBox(
              height: 50,
            ),
            ListView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = categories[index];
                return Column(
                  children: [
                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text((index + 1).toString()),
                          SizedBox(width: 80),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(data['category_photo']),
                          ),
                          SizedBox(width: 80),
                        ],
                      ),
                      title: Text(data['category_name']),
                      trailing: SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  eid = data['category_id'];
                                  categoryController.text =
                                      data['category_name'];
                                  imageUrl = data['category_photo'];
                                });
                              },
                              icon: Icon(Icons.edit),
                              color: const Color.fromARGB(255, 27, 1, 69),
                            ),
                            IconButton(
                              onPressed: () {
                                delete(data['category_id']);
                              },
                              icon: Icon(Icons.delete),
                              color: const Color.fromARGB(255, 250, 34, 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Spacing between rows
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
