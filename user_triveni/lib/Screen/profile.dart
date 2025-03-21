import 'package:user_triveni/Screen/changepassword.dart';
import 'package:user_triveni/Screen/edit.dart';
import 'package:user_triveni/Screen/viewcomplaint.dart';
import 'package:user_triveni/main.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userid = {};

  Future<void> fetchuser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        userid = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchuser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userid['user_photo'] ?? ""),
                  backgroundColor: Colors.grey.shade200,
                ),
                SizedBox(height: 20),
                Text(
                  userid['user_name'] ?? "User Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color.fromARGB(255, 54, 3, 116),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        userid['user_address'] ?? "Address unavailable",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: Color.fromARGB(255, 54, 3, 116),
                    ),
                    SizedBox(width: 6),
                    Text(
                      userid['user_contact'] ?? "No contact info",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 16,
                      color: Color.fromARGB(255, 54, 3, 116),
                    ),
                    SizedBox(width: 6),
                    Text(
                      userid['user_email'] ?? "No email",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Edit(),
                              ));
                        },
                        child: Text("Edit")),
                    SizedBox(
                      width: 50,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Changepassword(),
                              ));
                        },
                        child: Text("Change password")),
                  ],
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Complaint(),
                          ));
                    },
                    child: Text("Change password")),
              ],
            ),
          );
        },
      ),
    );
  }
}
