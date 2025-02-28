import 'package:user_triveni/Screen/homepage.dart';
import 'package:user_triveni/Screen/registerpage.dart';
import 'package:user_triveni/main.dart';
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
      print(email);
      print(password);
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
      print("Error During login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color.fromARGB(255, 3, 1, 68),
                width: 3,
              )),
          width: 340,
          height: 440,
          margin: EdgeInsets.only(top: 50),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(40),
            children: [
              Icon(
                Icons.people_alt,
                color: const Color.fromARGB(255, 3, 1, 68),
                size: 80,
              ),
              SizedBox(
                height: 30,
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
                controller: passwordController,
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
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 3, 1, 68),
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
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 12, 15, 15),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Registerpage(), // Replace with your Register Page
                        ),
                      );
                    },
                    child: Text(
                      "Register",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 15, 2, 100),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
