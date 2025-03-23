import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Wrejectectedlist extends StatefulWidget {
  const Wrejectectedlist({super.key});

  @override
  State<Wrejectectedlist> createState() => _WrejectectedlistState();
}

class _WrejectectedlistState extends State<Wrejectectedlist> {
  List<Map<String, dynamic>> weavers = [];

  Future<void> fetchweaver() async {
    try {
      final response = await supabase
          .from('tbl_weaver')
          .select()
          .eq('weaver_status', 2)
          .order('created_at', ascending: true);
      setState(() {
        weavers = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchweaver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: weavers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 2, // Adjusted for better proportions
              ),
              itemCount: weavers.length,
              itemBuilder: (context, index) {
                final data = weavers[index];

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
                                NetworkImage(data['weaver_photo'] ?? ""),
                            backgroundColor: Colors.grey.shade200,
                          ),
                          SizedBox(width: 18), // Space between image and text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['weaver_name'] ?? " ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  data['weaver_address'] ?? " ",
                                ),
                                Text(
                                  data['weaver_contact'] ?? " ",
                                ),
                                Text(
                                  data['weaver_email'] ?? " ",
                                ),
                                Text(
                                  data['weaver_password'] ?? " ",
                                ),
                              ],
                            ),
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
