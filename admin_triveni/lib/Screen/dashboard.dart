import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person),
                        Text("Weaver"),
                      ],
                    ),
                    Text("50"),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person),
                        Text("Artisan"),
                      ],
                    ),
                    Text("50"),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person),
                        Text("User"),
                      ],
                    ),
                    Text("50"),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person),
                        Text("Product"),
                      ],
                    ),
                    Text("50"),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset("asset.Logo.jpeg"),
                        Text("Name"),
                      ],
                    ),
                    Text("50"),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
