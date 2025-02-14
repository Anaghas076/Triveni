import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/changepassword.dart';
import 'package:user_triveni/Screen/edit.dart';
import 'package:user_triveni/Screen/profile.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profile(),
                      ));
                },
                child: Text("My Profile")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Edit(),
                      ));
                },
                child: Text("Edit Profile")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Changepassword(),
                      ));
                },
                child: Text(" Change Password")),
          ],
        ),
      ),
    );
  }
}
