import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/Cart.dart';

class Homecontent extends StatelessWidget {
  const Homecontent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  "Categorized by",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("asset/Men_1.jpg"),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Men",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("asset/Men_1.jpg"),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Women",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage("asset/Men_1.jpg"),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Kids",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Text(
              "Customized Product",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 5,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cart(),
                            ));
                      },
                      child: Card(
                        color: Colors.grey[200],
                        child: Column(
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15)),
                                image: DecorationImage(
                                  image: AssetImage("asset/Men_1.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text("Shirt and Dhoti"),
                            Text("Golden and Golden Border Dhoti"),
                            Text("Fabric:Cotton"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cart(),
                            ));
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Cart(),
                              ));
                        },
                        child: Card(
                          color: Colors.grey[200],
                          child: Column(
                            children: [
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  image: DecorationImage(
                                    image: AssetImage("asset/Men_2.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text("Salwar Set"),
                              Text("Golden and Golden Border Dhoti"),
                              Text("Fabric:Cotton"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ));
                  },
                  child: Card(
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            image: DecorationImage(
                              image: AssetImage("asset/Women_1.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text("Salwar Set"),
                        Text("Golden and Golden Border Dhoti"),
                        Text("Fabric:Cotton"),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ));
                  },
                  child: Card(
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            image: DecorationImage(
                              image: AssetImage("asset/Women_2.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text("Shirt and Dhoti"),
                        Text("Violet shirt and Golden Border Dhoti"),
                        Text("Fabric:Cotton"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ));
                  },
                  child: Card(
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            image: DecorationImage(
                              image: AssetImage("asset/Women_1.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text("Shirt and Dhoti"),
                        Text("Golden and Golden Border Dhoti"),
                        Text("Fabric:Cotton"),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ));
                  },
                  child: Card(
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            image: DecorationImage(
                              image: AssetImage("asset/Women_1.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text("Salwar Set"),
                        Text("Violet shirt and Golden Border Dhoti"),
                        Text("Fabric:Cotton"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ));
                  },
                  child: Card(
                    //shape top left and right
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            image: DecorationImage(
                              image: AssetImage("asset/Women_1.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text("Salwar Set"),
                        Text("Golden and Golden Border Dhoti"),
                        Text("Fabric:Cotton"),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cart(),
                        ));
                  },
                  child: Card(
                    color: Colors.grey[200],
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            image: DecorationImage(
                              image: AssetImage("asset/Women_1.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text("Shirt and Dhoti"),
                        Text("Violet shirt and Golden Border Dhoti"),
                        Text("Fabric:Cotton"),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
