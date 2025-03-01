import 'package:flutter/material.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  List<Map<String, dynamic>> bookingData = [
    {
      'name': "Daksha Combo",
      'price': "1000",
      'quantity': "2",
      'code': "TRVNI100",
      'subcategory': "Combo",
      'image': "asset/Men_1.jpg",
    },
    {
      'name': "Daksha Combo",
      'price': "1000",
      'quantity': "2",
      'subcategory': "Combo",
      'code': "TRVNI100",
      'image': "asset/Men_2.jpg",
    },
    {
      'name': "Davni Salwar",
      'price': "1500",
      'quantity': "2",
      'code': "TRVNI100",
      'subcategory': "Salwar",
      'image': "asset/Women_1.jpg",
    },
    {
      'name': "Davni Salwar",
      'price': "1500",
      'quantity': "2",
      'code': "TRVNI100",
      'subcategory': "Salwar",
      'image': "asset/Women_2.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          "My MyOrder",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final data = bookingData[index];
              return ListTile(
                leading: Text((index + 1).toString()),
                title: Text(data['name']),
                subtitle: Text(data['subcategory']),
                trailing: SizedBox(
                  width: 300,
                  child: Row(
                    children: [
                      Text(data['code']),
                      SizedBox(
                        width: 20,
                      ),
                      Text(data['quantity']),
                      SizedBox(
                        width: 20,
                      ),
                      Text(data['price']),
                      SizedBox(
                        width: 20,
                      ),
                      CircleAvatar(
                        backgroundImage: AssetImage(data['image']),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        onPressed: () {
                          //   delete(data['design_id'] ?? "");
                        },
                        icon: Icon(Icons.delete),
                        color: const Color.fromARGB(255, 250, 34, 10),
                      ),
                    ],
                  ),
                ),
              );
            },
            itemCount: bookingData.length,
          ),
        ),
      ),
    );
  }
}
