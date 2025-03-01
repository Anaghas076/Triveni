import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';

class Productdemo extends StatefulWidget {
  final Map<String, dynamic> product;
  const Productdemo({super.key, required this.product});

  @override
  State<Productdemo> createState() => _ProductdemoState();
}

class _ProductdemoState extends State<Productdemo> {
  Future<void> add(int pid) async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('booking_status', 0)
          .maybeSingle(); // Use maybeSingle() instead of single()

      if (response == null) {
        print("No existing booking, creating a new one.");
        int bookingid = await booking();
        checkCartProduct(pid, bookingid);
      } else {
        int bookingid = response['booking_id'];
        checkCartProduct(pid, bookingid);
      }
    } catch (e) {
      print("Error checking booking: $e");
    }
  }

  Future<int> booking() async {
    try {
      final response =
          await supabase.from('tbl_booking').insert({}).select().single();

      int id = response['booking_id'];
      return id;
    } catch (e) {
      print("Error cart: $e");
      return 0;
    }
  }

  Future<void> checkCartProduct(int pid, int bid) async {
    try {
      final response = await supabase
          .from('tbl_cart')
          .select()
          .eq('product_id', pid)
          .eq('booking_id', bid);
      if (response.isEmpty) {
        await supabase
            .from('tbl_cart')
            .insert({'booking_id': bid, 'product_id': pid});
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Added to Cart")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Already added to cart")));
      }
    } catch (e) {
      print("Error in Adding:$e");
    }
  }

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
              Image.network(
                widget.product['product_photo'],
                width: 200,
                height: 200,
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
                    add(widget.product['product_id']);
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
