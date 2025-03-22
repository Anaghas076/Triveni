import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';

class Productdemo extends StatefulWidget {
  final Map<String, dynamic> product;
  const Productdemo({super.key, required this.product});

  @override
  State<Productdemo> createState() => _ProductdemoState();
}

class _ProductdemoState extends State<Productdemo> {
  String selectedSize = "";
  List<Map<String, dynamic>> gallery = [];
  List<Map<String, dynamic>> reviews = [];
  Map<String, dynamic> userNames = {};
  double averageRating = 0.0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    fetchGalleryImages();
    fetchReviews();
  }

  Future<void> fetchGalleryImages() async {
    try {
      final response = await supabase
          .from('tbl_gallery')
          .select('gallery_photo')
          .eq('product_id', widget.product['product_id']); // Correct reference

      print("Fetched gallery images: $response"); // Debugging

      if (response.isNotEmpty) {
        setState(() {
          gallery = response;
        });
      }
    } catch (e) {
      print("Error fetching gallery images: $e");
    }
  }

  Future<void> add(int pid) async {
    try {
      final response = await supabase
          .from('tbl_booking')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
          .eq('booking_status', 0)
          .maybeSingle()
          .limit(1);
      if (response == null) {
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
      return response['booking_id'];
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
          .eq('product_size', selectedSize)
          .eq('booking_id', bid);
      if (response.isEmpty) {
        await supabase.from('tbl_cart').insert({
          'booking_id': bid,
          'product_id': pid,
          'product_size': selectedSize,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Added to Cart"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Already added to cart"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));
      }
    } catch (e) {
      print("Error in Adding:$e");
    }
  }

  Future<void> fetchReviews() async {
    try {
      final response = await supabase
          .from('tbl_review')
          .select()
          .eq('product_id', widget.product['product_id']);

      final reviewsList = List<Map<String, dynamic>>.from(response);
      double totalRating = 0;
      for (var review in reviewsList) {
        totalRating += double.parse(review['review_rating'].toString());
      }

      double avgRating =
          reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;
      print("Review: $reviews");
      setState(() {
        reviews = reviewsList;
        averageRating = avgRating;
        reviewCount = reviewsList.length;
      });

      for (var review in reviews) {
        final userId = review['user_id'];
        if (userId != null) {
          final userResponse = await supabase
              .from('tbl_user')
              .select('user_name')
              .eq('user_aid', userId)
              .single();

          setState(() {
            userNames[userId] = userResponse['user_name'] ?? 'Anonymous';
          });
        }
      }
    } catch (e) {
      print('Error fetching reviews: $e');
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
              if (gallery.isNotEmpty)
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Horizontal scrolling
                    itemCount: gallery.length,

                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Image.network(
                          gallery[index][
                              'gallery_photo'], // Display fetched gallery images
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                )
              else
                Image.network(
                  widget.product['product_photo'],
                  width: 200,
                  height: 200,
                ),
              SizedBox(height: 10),
              if (widget.product['product_size'] == true)
                Container(
                  width: 500,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ["S", "M", "L", "XL"].map((size) {
                      return Row(
                        children: [
                          Radio<String>(
                            activeColor: Colors.white,
                            fillColor: WidgetStatePropertyAll(Colors.grey),
                            value: size,
                            groupValue: selectedSize,
                            onChanged: (value) {
                              setState(() {
                                selectedSize = value!;
                              });
                            },
                          ),
                          Text(
                            size,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 3, 1, 68),
                                fontSize: 17),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 10),
              Text(widget.product['product_price'].toString()),
              SizedBox(height: 10),
              Text(widget.product['product_code']),
              SizedBox(height: 10),
              Text(widget.product['product_type']),
              SizedBox(height: 10),
              Text(widget.product['product_description']),
              SizedBox(height: 20),
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
            ],
          ),
          SizedBox(
            height: 10,
          ),
          // Reviews Section
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Customer Reviews",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 16),

                // Reviews List
                reviews.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'No reviews yet. Be the first to review!',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: reviews.map((review) {
                          final userId = review['user_id'];
                          final userName = userNames[userId] ?? 'Anonymous';
                          final rating =
                              double.parse(review['review_rating'].toString());

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          Color(0xFF64B5F6).withOpacity(0.2),
                                      child: Text(
                                        userName.substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: Color(0xFF64B5F6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${DateTime.parse(review['created_at']).toLocal().toString().split(' ')[0]}',
                                          style: TextStyle(
                                            color: Color(0xFF999999),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            Color(0xFF64B5F6).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Color(0xFFFFD700),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            rating.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    review['review_content'] ?? 'No comment',
                                    style: TextStyle(
                                      color: Color(0xFF666666),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
