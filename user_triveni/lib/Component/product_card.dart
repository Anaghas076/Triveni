import 'package:flutter/material.dart';

import 'package:user_triveni/Screen/productdemo.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> productData;
  const ProductCard({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Productdemo(
                product: productData,
              ),
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
                  image: NetworkImage(productData['product_photo']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              productData['product_name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            Text(
              productData['product_type'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.star, size: 20, color: Colors.amber),
                  Icon(Icons.star, size: 20, color: Colors.amber),
                  Icon(Icons.star, size: 20, color: Colors.amber),
                  Icon(Icons.star, size: 20, color: Colors.amber),
                  Icon(Icons.star, size: 20, color: Colors.amber),
                  SizedBox(width: 10),
                  Text(
                    productData['rating'].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3),
            Text(
              "₹${productData['product_price']}",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
