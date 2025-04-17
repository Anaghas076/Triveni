import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_triveni/component/formvalidation.dart';
import 'package:user_triveni/main.dart';

class Custom extends StatefulWidget {
  final int cartId;
  const Custom({super.key, required this.cartId});

  @override
  State<Custom> createState() => _CustomState();
}

class _CustomState extends State<Custom> {
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

      await supabase.storage.from('custom').upload(formattedDate, _image!);

      // Get public URL of the uploaded image
      final imageUrl =
          supabase.storage.from('custom').getPublicUrl(formattedDate);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  final TextEditingController designController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> submit() async {
    try {
      if (_image == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Pick an image first')));
      } else {
        String? imageUrl = await _uploadImage();
        String description = descriptionController.text;

        await supabase.from('tbl_customization').insert({
          'customization_photo': imageUrl,
          'customization_description': description,
          'cart_id': widget.cartId,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Order update: custom order requires an extra fee, confirmed by the admin before payment."),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));
        setState(() {
          _image = null;
        });
        descriptionController.clear();
      }
    } catch (e) {
      print("Error customization: $e");
    }
  }

  Future<void> _showDesignsDialog() async {
    List<Map<String, dynamic>> designs = [];

    try {
      final response = await supabase.from('tbl_design').select();
      designs = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching designs: $e");
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                  title: Text(
                    "Select Design",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Flexible(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: designs.length,
                      itemBuilder: (context, index) {
                        final data = designs[index];
                        return GestureDetector(
                          onTap: () async {
                            try {
                              final response = await http
                                  .get(Uri.parse(data['design_photo']));
                              final bytes = response.bodyBytes;
                              final tempDir = await getTemporaryDirectory();
                              final tempFile =
                                  File('${tempDir.path}/temp_design.jpg');
                              await tempFile.writeAsBytes(bytes);

                              setState(() {
                                _image = tempFile;
                              });
                              Navigator.pop(context);
                            } catch (e) {
                              print("Error selecting design: $e");
                            }
                          },
                          child: Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(data['design_photo']),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    data['design_name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          "Custom Order",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.image,
              color: Colors.white,
            ),
            onPressed: _showDesignsDialog,
          ),
        ],
      ),
      body: Form(
        key: formkey,
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
              validator: (value) => FormValidation.validateDescription(value),
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: 15,
              style: TextStyle(
                  color: const Color.fromARGB(255, 3, 1, 68),
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 10, 10, 10),
                    )),
                // prefixIcon: Icon(
                //   Icons.description,
                //   color: const Color.fromARGB(255, 7, 2, 54),
                // ),
                hintText:
                    " Description \n Work \n Size \n Color \n Other Specific Requests",

                hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 169, 168, 168),
                    fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 3, 1, 68),
                  ),
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      submit();
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
