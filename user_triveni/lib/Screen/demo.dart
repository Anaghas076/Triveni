import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/postcomplaint.dart';
import 'package:user_triveni/Screen/viewdesign.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Viewdesign(),
                    ));
              },
              child: Text("ViewDesign")),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Postcomplaint(),
                    ));
              },
              child: Text("PostComplaint")),
        ],
      ),
    );
  }
}
