import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_triveni/Component/formvalidation.dart';
import 'package:user_triveni/Screen/cart.dart';
import 'package:user_triveni/Screen/myorder.dart';
import 'package:user_triveni/Screen/viewdesign.dart';
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
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Cart(),
            ));

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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Viewdesign(),
                  ));
            },
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
                hintText: " Description",
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
