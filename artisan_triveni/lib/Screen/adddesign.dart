import 'package:artisan_triveni/main.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddDesign extends StatefulWidget {
  const AddDesign({super.key});

  @override
  State<AddDesign> createState() => _AddDesignState();
}

class _AddDesignState extends State<AddDesign> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print(pickedFile.name);
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final timestamp = DateTime.now();
      final formattedDate =
          'Design-${timestamp.day}-${timestamp.month}-${timestamp.year}-${timestamp.hour}-${timestamp.minute}';

      await supabase.storage.from('design').upload(formattedDate, _image!);

      // Get public URL of the uploaded image
      final imageUrl =
          supabase.storage.from('design').getPublicUrl(formattedDate);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  final TextEditingController nameController = TextEditingController();

  List<Map<String, dynamic>> designs = [];

  Future<void> submit() async {
    try {
      String name = nameController.text;

      String? imageUrl = await _uploadImage();
      await supabase.from('tbl_design').insert({
        'design_name': name,
        'design_photo': imageUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      nameController.clear();
      setState(() {
        _image = null;
      });
      fetchdesign();
    } catch (e) {
      print("Error design: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_design').delete().eq('design_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchdesign();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchdesign() async {
    try {
      final response = await supabase.from('tbl_design').select();
      setState(() {
        designs = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchdesign();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt,
                          color: Colors.white, size: 30)
                      : null,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: nameController,
              style: TextStyle(
                  color: const Color.fromARGB(255, 3, 1, 68),
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 10, 10, 10),
                    )),
                prefixIcon: Icon(
                  Icons.description,
                  color: const Color.fromARGB(255, 7, 2, 54),
                ),
                hintText: " Name",
                hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 8, 8, 8),
                    fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  submit();
                },
                child: Text("Submit")),
            SizedBox(
              height: 50,
            ),
            Container(
              decoration: BoxDecoration(
                  //color: const Color.fromARGB(255, 54, 3, 116),
                  ),
              child: ListView.builder(
                itemCount: designs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final data = designs[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['design_photo'] ?? ""),
                    ),
                    title: Text(
                      data['design_name'] ?? "",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 3, 1, 68),
                      ),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              delete(data['design_id'] ?? "");
                            },
                            icon: Icon(Icons.delete),
                            color: const Color.fromARGB(255, 250, 34, 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
