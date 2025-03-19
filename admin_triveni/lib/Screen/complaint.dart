import 'package:admin_triveni/Screen/reply.dart';
import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

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
          .select("*, tbl_user(*)")
          .eq('complaint_status', 0);

      print(response);

      setState(() {
        complaints = response;
      });
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaint();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final data = complaints[index];
            final user = data['tbl_user']; // tbl_user contains the user details
            return Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${user['user_name'] ?? ""}"),
                    SizedBox(height: 5),
                    Text("Contact: ${user['user_contact'] ?? ""}"),
                    SizedBox(height: 5),
                    Text(
                      data['complaint_title'] ?? " ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      data['complaint_description'] ?? " ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Reply(complaintId: data['complaint_id']),
                            ));
                      },
                      child: Text('Reply'),
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
