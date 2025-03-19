import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/Demo.dart';
import 'package:user_triveni/Screen/productdemo.dart';
import 'package:user_triveni/main.dart';

class Homecontent extends StatefulWidget {
  const Homecontent({super.key});

  @override
  State<Homecontent> createState() => _HomecontentState();
}

class _HomecontentState extends State<Homecontent> {
  List<Map<String, dynamic>> categories = [];

  Future<void> fetchCategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categories = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Categorized By Section
            SizedBox(height: 10),
            Center(
              child: Text(
                "Categorized by",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Categories Grid
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.9,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final data = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Productdemo(product: data),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(data['category_photo']),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(data['category_name'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 5),

            Center(
              child: Text(
                "Customized Product",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10,
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
                                builder: (context) => Demo(),
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
                              Text("Daksha Combo"),
                              // Text(data['product_code']),

                              Text(
                                "Predesigned",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text("1500"),
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
                                builder: (context) => Demo(),
                              ));
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Demo(),
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
                                Text("Daksha Combo"),
                                // Text(data['product_code']),

                                Text(
                                  "Predesigned",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text("1500"),
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
                            builder: (context) => Demo(),
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
                          Text("Daksha Combo"),
                          // Text(data['product_code']),

                          Text(
                            "Predesigned",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("1500"),
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
                            builder: (context) => Demo(),
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
                          Text("Daksha Combo"),
                          // Text(data['product_code']),

                          Text(
                            "Predesigned",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("1500"),
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
                            builder: (context) => Demo(),
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
                                image: AssetImage("asset/Set_1.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text("Daksha Set"),
                          // Text(data['product_code']),

                          Text(
                            "Customizable",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("1500"),
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
                            builder: (context) => Demo(),
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
                                image: AssetImage("asset/Set_2.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text("Daksha Set"),
                          // Text(data['product_code']),

                          Text(
                            "Predesigned",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("1500"),
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
                            builder: (context) => Demo(),
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
                                image: AssetImage("asset/Women_3.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text("Daksha Set"),
                          // Text(data['product_code']),

                          Text(
                            "Predesigned",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("1500"),
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
                            builder: (context) => Demo(),
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
                                image: AssetImage("asset/Women_4.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text("Daksha Set"),
                          // Text(data['product_code']),

                          Text(
                            "Predesigned",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text("1500"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
