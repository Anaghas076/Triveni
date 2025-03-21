import 'package:weaver_triveni/Screen/changepassword.dart';
import 'package:weaver_triveni/Screen/edit.dart';
import 'package:weaver_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:weaver_triveni/Screen/changepassword.dart';
import 'package:weaver_triveni/Screen/edit.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> weaverid = {};

  Future<void> fetchweaver() async {
    try {
      final response = await supabase
          .from('tbl_weaver')
          .select()
          .eq('weaver_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        weaverid = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchweaver();
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
                  backgroundImage: NetworkImage(weaverid['weaver_photo'] ?? ""),
                  backgroundColor: Colors.grey.shade200,
                ),
                SizedBox(height: 20),
                Text(
                  weaverid['weaver_name'] ?? "weaver Name",
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
                        weaverid['weaver_address'] ?? "Address unavailable",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
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
                      weaverid['weaver_contact'] ?? "No contact info",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
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
                      weaverid['weaver_email'] ?? "No email",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
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
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
