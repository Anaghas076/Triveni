import 'package:artisan_triveni/Screen/homepage.dart';
import 'package:artisan_triveni/Screen/registerpage.dart';
import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Future<void> login() async {
    try {
      String email = emailController.text;
      String password = passwordController.text;
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(),
          ));
      print("Login Successfull");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error Login')));
      print("Error During login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      body: Center(
        child: Container(
          width: 650,
          height: 650,
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CircleAvatar(
                    backgroundImage: AssetImage("asset/Logo.jpeg"),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "TRIVENI",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: 200,
                  height: 80,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      "GET STARTED",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text("Don't have an account?",
                    style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Registerpage(),
                        ),
                      );
                    },
                    child: Text("Register Here",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: const Color.fromARGB(255, 3, 1, 68),
                          // decorationThickness: 1.0,
                          color: const Color.fromARGB(255, 3, 1, 68),
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
