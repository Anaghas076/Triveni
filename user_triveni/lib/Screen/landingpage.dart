import 'package:flutter/material.dart';
import 'package:user_triveni/screen/loginpage.dart';

import 'package:user_triveni/screen/registerpage.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
