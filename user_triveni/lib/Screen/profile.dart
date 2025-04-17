import 'package:user_triveni/Screen/loginpage.dart';
import 'package:user_triveni/screen/changepassword.dart';
import 'package:user_triveni/screen/edit.dart';
import 'package:user_triveni/screen/viewcomplaint.dart';
import 'package:user_triveni/screen/wallet.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              margin: EdgeInsets.all(20),
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 3, 1, 68),
                    Color.fromARGB(255, 54, 3, 116),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(userid['user_photo'] ?? ""),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        userid['user_name'] ?? "User Name",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Profile Information Cards
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Contact Information Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contact Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 3, 1, 68),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.email,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Email"),
                            subtitle: Text(userid['user_email'] ?? "No email"),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Phone"),
                            subtitle:
                                Text(userid['user_contact'] ?? "No contact"),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Address"),
                            subtitle:
                                Text(userid['user_address'] ?? "No address"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Quick Actions Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 3, 1, 68),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.edit,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Edit Profile"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Edit()),
                              ).then((value) {
                                if (value == true) {
                                  fetchuser();
                                }
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.lock,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Change Password"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Changepassword()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.report_problem,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Complaints"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Complaint()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.wallet,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Wallet"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WalletPage()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout_rounded,
                                color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Log Out"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Log Out"),
                                    content: Text(
                                        "Are you sure you want to log out?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await supabase.auth.signOut();
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LoginPage(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        child: Text("Log Out"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
