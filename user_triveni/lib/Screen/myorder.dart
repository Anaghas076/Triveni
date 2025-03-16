import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/postcomplaint.dart';

class Myorder extends StatefulWidget {
  @override
  _MybookingDataState createState() => _MybookingDataState();
}

class _MybookingDataState extends State<Myorder> {
  final List<Map<String, String>> bookingData = [
    {
      "status": "Processing",
      "price": "1000",
      "name": "Daksha Combo",
      "quantity": "1",
      "date": "Today",
      "orderId": "12345",
      "image": "asset/Men_1.jpg"
    },
    {
      "status": "Delivered",
      "price": "1000",
      "name": "Daksha Combo",
      "quantity": "1",
      "date": "23 Aug, 2020",
      "orderId": "12345",
      "image": "asset/Men_1.jpg"
    },
    {
      "status": "Delivered",
      "price": "1000",
      "name": "Daksha Combo",
      "quantity": "1",
      "date": "20 Aug, 2020",
      "orderId": "12345",
      "image": "asset/Men_1.jpg"
    },
    {
      "status": "Cancelled",
      "name": "Daksha Combo",
      "price": "1000",
      "quantity": "1",
      "date": "20 Aug, 2020",
      "orderId": "12345",
      "image": "asset/Men_1.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: bookingData.length,
        itemBuilder: (context, index) {
          final data = bookingData[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Image.asset(data['image']!,
                          width: 60, height: 53, fit: BoxFit.cover),
                      SizedBox(height: 10),
                      Text(
                        "QTY: ${data['quantity']}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name']!,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("Order ID: ${data['orderId']}",
                            style: TextStyle(fontSize: 14)),
                        SizedBox(height: 10),
                        Text("Price: ${data['price']}",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(data['date']!,
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      SizedBox(height: 10),
                      Text(data['status']!,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 100,
                        height: 30,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 3, 1, 68),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Postcomplaint(),
                                  ));
                            },
                            child: Text(
                              "Complaint",
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
