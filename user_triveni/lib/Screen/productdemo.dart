import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/cart.dart';

class Productdemo extends StatefulWidget {
  final Map<String, dynamic> product;
  const Productdemo({super.key, required this.product});

  @override
  State<Productdemo> createState() => _ProductdemoState();
}

class _ProductdemoState extends State<Productdemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  image: widget.product['product_photo'],
                ),
              ),
              Container(
                child: Image.network(
                  widget.product['product_photo'],
                  width: 400,
                  height: 400,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(widget.product['product_price']),
              SizedBox(
                height: 10,
              ),
              Text(widget.product['product_code']),
              SizedBox(
                height: 10,
              ),
              Text(widget.product['product_type']),
              SizedBox(
                height: 10,
              ),
              Text(widget.product['product_description']),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 50,
                width: 350,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                  ),
                  onPressed: () {
                    //cart();
                  },
                  child: Text(
                    "Add to Cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                width: 350,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                  ),
                  onPressed: () {
                    //cart();
                  },
                  child: Text(
                    "Buy Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
