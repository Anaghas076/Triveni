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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // Adjust based on requirement
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 5, // Adjust for better layout
            ),
            itemCount: customs.length,
            itemBuilder: (context, index) {
              final data = customs[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox.expand(
                    // Expands to fit available height
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Centers all content
                      children: [
                        Spacer(), // Push content down
                        Container(
                          width: 100, // Square size
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(
                                  data['customization_photo'] ?? ""),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          data['customization_description'] ??
                              "No description available",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        Spacer(), // Push content up
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
