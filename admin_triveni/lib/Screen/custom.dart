import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Viewdesign extends StatefulWidget {
  final int cartId;
  const Viewdesign({super.key, required this.cartId});

  @override
  _ViewdesignState createState() => _ViewdesignState();
}

class _ViewdesignState extends State<Viewdesign> {
  List<Map<String, dynamic>> customs = [];

  Future<void> fetchdesign() async {
    try {
      final response = await supabase
          .from('tbl_customization')
          .select()
          .eq('cart_id', widget.cartId);
      setState(() {
        customs = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdesign();
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
        title: Text(
          "View Design",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: customs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5, // Adjusted for better layout
                  ),
                  itemCount: customs.length,
                  itemBuilder: (context, index) {
                    final data = customs[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 150, // Further reduced height
                            width: 150, // Further reduced width
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image:
                                    NetworkImage(data['customization_photo']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data['customization_description'] ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12), // Reduced font size
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
