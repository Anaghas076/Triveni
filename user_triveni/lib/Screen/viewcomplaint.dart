import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';
import 'package:intl/intl.dart';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  List<Map<String, dynamic>> complaints = [];

  Future<void> fetchComplaint() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select("*, tbl_product(*), tbl_user(*)") // Include user details
          .eq('user_id', supabase.auth.currentUser!.id);

      print(response);

      setState(() {
        complaints = response;
      });
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  String formatDate(String timestamp) {
    DateTime parsedDate = DateTime.parse(timestamp);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

  @override
  void initState() {
    super.initState();
    fetchComplaint();
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
          "My Complaint",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: complaints.isEmpty
            ? Center(
                child: Text(
                  "No Complaints Found",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final data = complaints[index];
                  final product = data['tbl_product'] ?? {};

                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Date: ${formatDate(data['created_at'])}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(),
                          Text(
                            "Product Code: ${product['product_code'] ?? "N/A"}",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Complaint: ${data['complaint_title'] ?? "N/A"}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            data['complaint_description'] ?? "No Description",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 3, 1, 68),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              data['complaint_reply'] ?? "No Reply Yet",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
