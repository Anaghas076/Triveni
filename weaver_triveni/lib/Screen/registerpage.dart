import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:weaver_triveni/component/formvalidation.dart';
import 'package:weaver_triveni/screen/homepage.dart';
import 'package:weaver_triveni/main.dart';

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
  File? _proofImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage(int imageNumber) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          _image = File(pickedFile.path);
        } else {
          _proofImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(
    File imageFile,
    String weaverId,
    String type,
  ) async {
    try {
      final fileName = 'weaver_${weaverId}_$type';

      await supabase.storage.from('weaver').upload(fileName, imageFile);

      // Get public URL of the uploaded image
      final imageUrl = supabase.storage.from('weaver').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> register() async {
    try {
      if (_image == null || _proofImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pick profile and proof images first')),
        );
        return;
      }

      String name = nameController.text;
      String address = addressController.text;
      String contact = contactController.text;
      String email = emailController.text;
      String password = passwordController.text;

      final response = await supabase.auth.signUp(
        password: password,
        email: email,
      );
      String weaverId = response.user!.id;

      String? imageUrl = await _uploadImage(_image!, weaverId, "profile");
      String? proofImageUrl = await _uploadImage(
        _proofImage!,
        weaverId,
        "proof",
      );

      await supabase.from('tbl_weaver').insert({
        'weaver_name': name,
        'weaver_address': address,
        'weaver_contact': contact,
        'weaver_email': email,
        'weaver_password': password,
        'weaver_photo': imageUrl,
        'weaver_proof': proofImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully registered!"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );

      nameController.clear();
      addressController.clear();
      contactController.clear();
      emailController.clear();
      passwordController.clear();
      confirmController.clear();

      print("Register Successfully");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Already Exist!!"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      );
      print("Error registering weaver: $e");
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
            // color: Colors.white,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color.fromARGB(255, 3, 1, 68),
                width: 3,
              ),
            ),
            width: 340,
            height: 750,
            margin: EdgeInsets.only(top: 50),
            child: ListView(
              padding: EdgeInsets.all(10),
              children: [
                // Profile Picture Upload
                Center(
                  child: GestureDetector(
                    onTap: () => _pickImage(1),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                  ),
                ),

                SizedBox(height: 10),
                TextFormField(
                  validator: (value) => FormValidation.validateName(value),
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 3, 1, 68),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Username",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 8, 8, 8),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (value) => FormValidation.validateAddress(value),
                  controller: addressController,
                  keyboardType: TextInputType.name,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 3, 1, 68),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.location_on,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Address",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 8, 8, 8),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (value) => FormValidation.validateContact(value),
                  controller: contactController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 3, 1, 68),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Contact number",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 8, 8, 8),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (value) => FormValidation.validateEmail(value),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 3, 1, 68),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        width: 3,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.email_sharp,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: "Email Address",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 8, 8, 8),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  validator: (value) => FormValidation.validatePassword(value),
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 3, 1, 68),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        width: 3,
                      ),
                    ),
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
                SizedBox(height: 10),
                TextFormField(
                  validator: (value) => FormValidation.validateConfirmPassword(
                    value,
                    passwordController.text,
                  ),
                  controller: confirmController,
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 3, 1, 68),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 10, 10, 10),
                        width: 3,
                      ),
                    ),
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
                SizedBox(height: 10),

                // Proof Image Upload
                Center(
                  child: GestureDetector(
                    onTap: () => _pickImage(2),
                    child: Container(
                      width: 400,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 7, 2, 54),
                          width: 2,
                        ),
                      ),
                      child: _proofImage != null
                          ? Image.file(_proofImage!, fit: BoxFit.cover)
                          : Icon(
                              Icons.file_upload,
                              size: 50,
                              color: const Color.fromARGB(255, 7, 2, 54),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Text(
                    "  Upload Proof (ID, Certification, etc.)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),

                // Register Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                  ),
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      register();
                    }
                  },
                  child: Text(
                    "REGISTER",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 236, 235, 235),
                      fontSize: 18,
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
