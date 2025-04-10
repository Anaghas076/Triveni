import 'package:flutter/material.dart';

import 'package:user_triveni/screen/productdemo.dart';

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
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(
                  productData['rating'].toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            Text(productData['product_code']),
            Text(productData['product_name']),
            Text(
              productData['product_type'],
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            Text(productData['product_price'].toString()),
          ],
        ),
      ),
    );
  }
}
