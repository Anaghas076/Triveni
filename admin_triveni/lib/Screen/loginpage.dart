import 'package:admin_triveni/Components/formvalidation.dart';
import 'package:admin_triveni/Screen/homepage.dart';
import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<void> signIn() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;
      print(email);
      print(password);
      final auth = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      String id = auth.user!.id;

      final admin = await supabase.from('tbl_admin').select().single();
      if (admin.isNotEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Homepage(),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid Credentials"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));
      }

      print("Login Successfull");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid Credentials"),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ));
      print("Error During login: $e");
    }
  }

  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            width: 400,
            margin: EdgeInsets.only(top: 50),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(40),
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 80,
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validateEmail(value),
                  controller: _emailController,
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
                      Icons.email_sharp,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: "Email Address",
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.w900,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  validator: (value) => FormValidation.validatePassword(value),
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 3, 1, 68),
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 3, 1, 68),
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
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formkey.currentState!.validate()) {
                      signIn();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 23, 2, 62),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "LOGIN",
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
          // CircleAvatar positioned to overlap the container
        ),
      ),
    );
  }
}
