import 'package:flutter/material.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage> {
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
                // controller: genderController,
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
                // controller: genderController,
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
                // controller: addressController,
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
                    Icons.streetview,
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
                // controller: contactController,
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
                height: 10,
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
                //  controller: confirmController,
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
              ElevatedButton(
                onPressed: () {
                  //register();
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
