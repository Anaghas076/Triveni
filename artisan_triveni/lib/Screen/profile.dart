import 'package:artisan_triveni/Screen/changepassword.dart';
import 'package:artisan_triveni/Screen/edit.dart';
import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> artisanid = {};

  Future<void> fetchartisan() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select()
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        artisanid = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchartisan();
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
                  backgroundImage:
                      NetworkImage(artisanid['artisan_photo'] ?? ""),
                  backgroundColor: Colors.grey.shade200,
                ),
                SizedBox(height: 20),
                Text(
                  artisanid['artisan_name'] ?? "Artisan Name",
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
                        artisanid['artisan_address'] ?? "Address unavailable",
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
                      artisanid['artisan_contact'] ?? "No contact info",
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
                      artisanid['artisan_email'] ?? "No email",
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
