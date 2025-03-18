import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:artisan_triveni/Component/formvalidation.dart';
import 'package:artisan_triveni/Screen/homepage.dart';
import 'package:artisan_triveni/main.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String artisanId) async {
    try {
      final fileName = 'artisan_$artisanId';

      await supabase.storage.from('artisan').upload(fileName, _image!);

      // Get public URL of the uploaded image
      final imageUrl = supabase.storage.from('artisan').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> register() async {
    try {
      if (_image == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Pick an image first')));
      } else {
        String name = nameController.text;
        String address = addressController.text;
        String contact = contactController.text;
        String email = emailController.text;
        String password = passwordController.text;

        final response =
            await supabase.auth.signUp(password: password, email: email);
        String artisanId = response.user!.id;

        String? imageUrl = await _uploadImage(artisanId);
        await supabase.from('tbl_artisan').insert({
          'artisan_name': name,
          'artisan_address': address,
          'artisan_contact': contact,
          'artisan_email': email,
          'artisan_password': password,
          'artisan_photo': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Successfully registed!!!!"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(),
            ));
        nameController.clear();
        addressController.clear();
        contactController.clear();
        emailController.clear();
        passwordController.clear();
        confirmController.clear();
        print("Register Successfully");
      }
    } catch (e) {
      print("Error artisan: $e");
    }
  }

  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: formkey,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color.fromARGB(255, 3, 1, 68),
                  width: 3,
                )),
            width: 340,
            height: 650,
            margin: EdgeInsets.only(top: 50),
            child: ListView(
              padding: EdgeInsets.all(20),
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
                          color: const Color.fromARGB(255, 10, 10, 10),
                          width: 3,
                        )),
                    prefixIcon: Icon(
                      Icons.person,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Username",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 8, 8, 8),
                        fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validateAddress(value),
                  controller: addressController,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 10, 10, 10),
                          width: 3,
                        )),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Address",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 8, 8, 8),
                        fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validateContact(value),
                  controller: contactController,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 10, 10, 10),
                          width: 3,
                        )),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Contact number",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 8, 8, 8),
                        fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validateEmail(value),
                  controller: emailController,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 10, 10, 10),
                          width: 3,
                        )),
                    prefixIcon: Icon(
                      Icons.email_sharp,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: "Email Address",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 8, 8, 8),
                        fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validatePassword(value),
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 10, 10, 10),
                          width: 3,
                        )),
                    prefixIcon: Icon(
                      Icons.password_outlined,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    suffixIcon: Icon(
                      Icons.visibility_off,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: "Password",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 10, 10, 10),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validateConfirmPassword(
                      value, passwordController.text),
                  controller: confirmController,
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 10, 10, 10),
                          width: 3,
                        )),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    suffixIcon: Icon(
                      Icons.visibility_off,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: "Confirm Password",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 10, 10, 10),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      register();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 23, 2, 62),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "REGISTER",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 236, 235, 235),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
