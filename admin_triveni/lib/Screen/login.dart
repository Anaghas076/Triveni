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
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(),
          ));
      print("SignIn Successfull");
    } catch (e) {
      print("Error During SignIn: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 400,
              height: 400,
              margin: EdgeInsets.only(top: 50), // To adjust for CircleAvatar
              decoration: BoxDecoration(
                color: Colors.yellowAccent,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 48, 48, 48).withOpacity(0.7),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListView(
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
                    controller: _emailController,
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
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
                    height: 30,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    style:
                        TextStyle(color: const Color.fromARGB(255, 10, 10, 10)),
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
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signIn();
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
          ],
        ),
      ),
    );
  }
}
