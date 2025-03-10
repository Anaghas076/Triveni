import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Arejectedlist extends StatefulWidget {
  const Arejectedlist({super.key});

  @override
  State<Arejectedlist> createState() => _WrejectectedlistState();
}

class _WrejectectedlistState extends State<Arejectedlist> {
  List<Map<String, dynamic>> artisans = [];

  Future<void> fetchartisan() async {
    try {
      final response =
          await supabase.from('tbl_artisan').select().eq('artisan_status', 2);
      setState(() {
        artisans = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchartisan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: artisans.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 2, // Adjusted for better proportions
              ),
              itemCount: artisans.length,
              itemBuilder: (context, index) {
                final data = artisans[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30, // Reduced size for better alignment
                        backgroundImage:
                            NetworkImage(data['artisan_photo'] ?? ""),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      SizedBox(width: 18), // Space between image and text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data['artisan_name'] ?? " ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              data['artisan_address'] ?? " ",
                            ),
                            Text(
                              data['artisan_contact'] ?? " ",
                            ),
                            Text(
                              data['artisan_email'] ?? " ",
                            ),
                            Text(
                              data['artisan_password'] ?? " ",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
