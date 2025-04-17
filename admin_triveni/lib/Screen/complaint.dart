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
          .order('created_at', ascending: false);

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
      appBar: AppBar(title: Text('Complaints')),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Adds border
          borderRadius: BorderRadius.circular(10), // Rounded corners
          color: Colors.white, // Background color
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20.0,
              columns: [
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Action')),
              ],
              rows: complaints.map((data) {
                final user = data['tbl_user'];
                return DataRow(cells: [
                  DataCell(Text(user['user_name'] ?? "")),
                  DataCell(Text(user['user_contact'] ?? "")),
                  DataCell(Text(data['complaint_title'] ?? "")),
                  DataCell(Text(data['complaint_description'] ?? "")),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: data['complaint_status'] == 0
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Reply(
                                        complaintId: data['complaint_id']),
                                  ),
                                );
                              },
                              child: Text('Reply'),
                            )
                          : Center(
                              child: Text(
                                'Replied',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 3, 1, 68),
                                ),
                              ),
                            ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
