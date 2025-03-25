import 'package:artisan_triveni/Component/formvalidation.dart';
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
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Pick an image first'),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));
      } else {
        String name = nameController.text;

        String? imageUrl = await _uploadImage();
        await supabase.from('tbl_design').insert({
          'design_name': name,
          'design_photo': imageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Inserted"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));
        nameController.clear();
        setState(() {
          _image = null;
        });
        fetchdesign();
      }
    } catch (e) {
      print("Error design: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_design').delete().eq('design_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ));
      fetchdesign();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchdesign() async {
    try {
      final response = await supabase
          .from('tbl_design')
          .select()
          .eq('artisan_id', supabase.auth.currentUser!.id);
      ;
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
          title: Text(
            "Add Design",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(padding: EdgeInsets.all(20), children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color.fromARGB(255, 3, 1, 68),
                  width: 3,
                )),
            child: Form(
              key: formkey,
              child: Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                        backgroundImage:
                            _image != null ? FileImage(_image!) : null,
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
                    validator: (value) => FormValidation.validateName(value),
                    controller: nameController,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 3, 1, 68),
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            width: 3,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    ),
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        submit();
                      }
                    },
                    child: Text("Submit",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Center(
            child: Container(
              width: 350, // Adjust width as needed
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  designs.isNotEmpty
                      ? ListView.builder(
                          itemCount: designs.length,
                          shrinkWrap: true,
                          physics:
                              NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
                          itemBuilder: (context, index) {
                            final data = designs[index];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(data['design_photo'] ?? ""),
                                ),
                                title: Text(
                                  data['design_name'] ?? "",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 3, 1, 68),
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    delete(data['design_id'] ?? "");
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ),
                            );
                          },
                        )
                      : Text(
                          "No designs available",
                          style: TextStyle(color: Colors.grey),
                        ),
                ],
              ),
            ),
          )
        ]));
  }
}
