import 'package:user_triveni/Screen/changepassword.dart';
import 'package:user_triveni/Screen/edit.dart';
import 'package:user_triveni/Screen/viewcomplaint.dart';
import 'package:user_triveni/Screen/wallet.dart';
import 'package:user_triveni/main.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic> userid = {};
  int walletBalance = 0;
  int walletCredit = 0;

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

  Future<void> fetchWalletDetails() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('tbl_wallet')
          .select('wallet_balance, wallet_credit')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          walletBalance = response['wallet_balance'] ?? 0;
          walletCredit = response['wallet_credit'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching wallet: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchuser();
    fetchWalletDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Wallet Balance",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("₹$walletBalance",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                    Divider(),
                    Text("Credited Points: $walletCredit",
                        style: TextStyle(fontSize: 14, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 2),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              NetworkImage(userid['user_photo'] ?? ""),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        SizedBox(height: 20),
                        Text(
                          userid['user_name'] ?? "user Name",
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
                                    fontSize: 14, color: Colors.black54),
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
                                  fontSize: 14, color: Colors.black54),
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
                                  fontSize: 14, color: Colors.black54),
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
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Complaint())),
              child: Text("View Complaints", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
