import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Weaverlist extends StatefulWidget {
  const Weaverlist({super.key});

  @override
  State<Weaverlist> createState() => _WeaverlistState();
}

class _WeaverlistState extends State<Weaverlist> {
  List<Map<String, dynamic>> weavers = [];

  Future<void> fetchweaver() async {
    try {
      final response = await supabase
          .from('tbl_weaver')
          .select()
          .eq('weaver_status', 0)
          .order('created_at', ascending: true);
      setState(() {
        weavers = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateWeaverStatus(String weaver_id, int status) async {
    try {
      await supabase.from('tbl_weaver').update({'weaver_status': status}).eq(
          'weaver_id', weaver_id); // Ensure UUID is treated as a String

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(status == 1 ? " Accepted" : " Rejected"),
        backgroundColor: const Color.fromARGB(255, 27, 1, 69),
      ));

      fetchweaver(); // Refresh list
    } catch (e) {
      print("Error updating status: $e");
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
                childAspectRatio: .75, // Adjusted for better proportions
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
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['weaver_proof'] ?? "",
                          width: 150,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              updateWeaverStatus(data['weaver_id'].toString(),
                                  1); // Convert UUID to String
                            },
                            child: Text("Accept"),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              updateWeaverStatus(data['weaver_id'].toString(),
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
