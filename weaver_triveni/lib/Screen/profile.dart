import 'package:weaver_triveni/Screen/changepassword.dart';
import 'package:weaver_triveni/Screen/daily.dart';
import 'package:weaver_triveni/Screen/edit.dart';
import 'package:weaver_triveni/Screen/report.dart';
import 'package:weaver_triveni/main.dart';
import 'package:flutter/material.dart';

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Background
            Container(
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
                        backgroundImage: NetworkImage(weaverid['weaver_photo'] ?? ""),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        weaverid['weaver_name'] ?? "Weaver Name",
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
                            leading: Icon(Icons.phone, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Phone"),
                            subtitle: Text(weaverid['weaver_contact'] ?? "No contact info"),
                          ),
                          ListTile(
                            leading: Icon(Icons.email, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Email"),
                            subtitle: Text(weaverid['weaver_email'] ?? "No email"),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Address"),
                            subtitle: Text(weaverid['weaver_address'] ?? "Address unavailable"),
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
                            leading: Icon(Icons.edit, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Edit Profile"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Edit()),
                              ).then((value) {
                                if (value == true) {
                                  fetchweaver();
                                }
                              });
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.lock, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Change Password"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Changepassword()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.assessment, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Work Analysis"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ReportPage()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.history, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Daily Transactions"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DailyWeaver()),
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
