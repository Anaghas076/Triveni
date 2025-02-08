import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 350,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Icon(
                Icons.people_alt,
                color: const Color.fromARGB(255, 3, 1, 68),
                size: 80,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                //  controller: emailController,
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
                height: 20,
              ),
              TextFormField(
                // controller: passwordController,
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
                    Icons.password,
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
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  //login();
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
      ),
    );
  }
}
