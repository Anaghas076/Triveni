import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Artisanlist extends StatefulWidget {
  const Artisanlist({super.key});

  @override
  State<Artisanlist> createState() => _ArtisanlistState();
}

class _ArtisanlistState extends State<Artisanlist> {
  List<Map<String, dynamic>> artisans = [];

  Future<void> fetchartisan() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select()
          .eq('artisan_status', 0)
          .order('created_at', ascending: false);

      setState(() {
        artisans = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateartisanStatus(String artisan_id, int status) async {
    try {
      await supabase.from('tbl_artisan').update({'artisan_status': status}).eq(
          'artisan_id', artisan_id); // Ensure UUID is treated as a String

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(status == 1 ? " Accepted" : " Rejected"),
        backgroundColor: status == 1 ? Colors.green : Colors.red,
      ));

      fetchartisan(); // Refresh list
    } catch (e) {
      print("Error updating status: $e");
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
                childAspectRatio: 1.5, // Adjusted for better proportions
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
                  child: Column(
                    children: [
                      Row(
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
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              updateartisanStatus(data['artisan_id'].toString(),
                                  1); // Convert UUID to String
                            },
                            child: Text("Accept"),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              updateartisanStatus(data['artisan_id'].toString(),
                                  2); // Fix incorrect reference
                            },
                            // style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.red),
                            child: Text("Reject"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
