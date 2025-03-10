import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final TextEditingController newController = TextEditingController();
  final TextEditingController oldController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  Future<void> change() async {
    try {
      await supabase.from('tbl_artisan').update({
        'artisan_password': newController.text,
      }).eq('artisan_id', supabase.auth.currentUser!.id);

      Navigator.pop(context, true); // Return true to refresh profile
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Change Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color.fromARGB(255, 3, 1, 68),
                width: 3,
              )),
          width: 350,
          height: 400,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.lock,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 80,
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: oldController,
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
                    hintText: "Old Password",
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
                  controller: newController,
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
                    hintText: " New Password",
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
                  controller: confirmController,
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
                    hintText: " Confirm Password",
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
                    change();
                  },
                  child: Text("Change"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
