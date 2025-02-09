import 'package:artisan_triveni/Screen/loginpage.dart';
import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController proofController = TextEditingController();
  final TextEditingController photoController = TextEditingController();

  Future<void> register() async {
    try {
      String name = nameController.text;
      String address = addressController.text;
      String contact = contactController.text;
      String email = emailController.text;
      String password = passwordController.text;
      String proof = proofController.text;
      String photo = photoController.text;

      await supabase.from('tbl_artisan').insert({
        'artisan_name': name,
        'artisan_address': address,
        'artisan_contact': contact,
        'artisan_email': email,
        'artisan_password': password,
        'artisan_proof': proof,
        'artisan_photo': photo,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Successfully registed!!!!"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ));
      nameController.clear();
      addressController.clear();
      contactController.clear();
      emailController.clear();
      passwordController.clear();
      confirmController.clear();
      proofController.clear();
      photoController.clear();
    } catch (e) {
      print("Error artisan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 680,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Icon(
                Icons.person,
                color: const Color.fromARGB(255, 3, 1, 68),
                size: 70,
              ),
              TextFormField(
                controller: photoController,
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
                    Icons.email_sharp,
                    color: const Color.fromARGB(255, 7, 2, 54),
                  ),
                  hintText: " Profile",
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
                controller: addressController,
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
                controller: contactController,
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
                controller: emailController,
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
              TextFormField(
                controller: proofController,
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
                    Icons.email_sharp,
                    color: const Color.fromARGB(255, 7, 2, 54),
                  ),
                  hintText: " Proof",
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
                  register();
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
    );
  }
}
