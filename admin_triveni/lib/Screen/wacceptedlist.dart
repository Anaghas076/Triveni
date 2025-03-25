import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Wacceptedlist extends StatefulWidget {
  const Wacceptedlist({super.key});

  @override
  State<Wacceptedlist> createState() => _WacceptedlistState();
}

class _WacceptedlistState extends State<Wacceptedlist> {
  List<Map<String, dynamic>> weavers = [];

  Future<void> fetchweaver() async {
    try {
      final response = await supabase
          .from('tbl_weaver')
          .select()
          .eq('weaver_status', 1)
          .order('created_at', ascending: true);

      setState(() {
        weavers = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching weavers: $e");
    }
  }

  Future<void> updateweaverStatus(String weaverId, int status) async {
    try {
      await supabase
          .from('tbl_weaver')
          .update({'weaver_status': status}).eq('weaver_id', weaverId);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("weaver Rejected"),
        backgroundColor: const Color.fromARGB(255, 27, 1, 69),
      ));

      fetchweaver(); // Refresh the list
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
                childAspectRatio: .85,
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
                            radius: 30,
                            backgroundImage:
                                NetworkImage(data['weaver_photo'] ?? ""),
                            backgroundColor: Colors.grey.shade200,
                          ),
                          SizedBox(width: 18),
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
                                Text(data['weaver_address'] ?? " "),
                                Text(data['weaver_contact'] ?? " "),
                                Text(data['weaver_email'] ?? " "),
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
                      SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () {
                          updateweaverStatus(data['weaver_id'].toString(), 2);
                        },
                        child: Text("Reject"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
