import 'package:flutter/material.dart';
import 'package:user_triveni/Screen/demo.dart';

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
                  image: NetworkImage(productData['product_photo']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(productData['product_code']),
            Text(productData['product_type']),
            Text(productData['product_price'].toString()),
          ],
        ),
      ),
    );
  }
}
