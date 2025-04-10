import 'package:artisan_triveni/screen/changepassword.dart';
import 'package:artisan_triveni/screen/daily.dart';
import 'package:artisan_triveni/screen/edit.dart';
import 'package:artisan_triveni/screen/report.dart';
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
                        backgroundImage: NetworkImage(artisanid['artisan_photo'] ?? ""),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        artisanid['artisan_name'] ?? "Artisan Name",
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
                            subtitle: Text(artisanid['artisan_contact'] ?? "No contact info"),
                          ),
                          ListTile(
                            leading: Icon(Icons.email, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Email"),
                            subtitle: Text(artisanid['artisan_email'] ?? "No email"),
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on, color: Color.fromARGB(255, 54, 3, 116)),
                            title: Text("Address"),
                            subtitle: Text(artisanid['artisan_address'] ?? "Address unavailable"),
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
                                  fetchartisan();
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
                                MaterialPageRoute(builder: (context) => ArtisanPage()),
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

