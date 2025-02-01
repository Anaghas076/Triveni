import 'dart:io';
import 'dart:typed_data';

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
      // await updateImage(uid, publicUrl);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> submit() async {
    try {
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
      fetchCategory();
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
    } catch (e) {}
  }

  int eid = 0;

  Future<void> update() async {
    try {
      await supabase.from('tbl_category').update({
        'category_name': categoryController.text,
      }).eq('category_id', eid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchCategory();
      categoryController.clear();
      setState(() {
        eid = 0;
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
    } catch (e) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Center(
              //pickimage code start...
              child: SizedBox(
                height: 120,
                width: 120,
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
            TextFormField(
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
                  if (eid == 0) {
                    submit();
                  } else {
                    update();
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
                return ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(data['category_name']),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              eid = data['category_id'];
                              categoryController.text = data['category_name'];
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
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
