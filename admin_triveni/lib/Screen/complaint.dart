import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  final TextEditingController replyController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaint();
  }

  Future<void> fetchComplaint() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select("*, tbl_user(*)")
          .order('created_at', ascending: false);

      setState(() {
        complaints = response;
      });
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  Future<void> sendReply(int complaintId) async {
    if (!formKey.currentState!.validate()) return;

    try {
      String reply = replyController.text.trim();

      if (complaintId == 0) {
        throw "Invalid complaint ID";
      }

      await supabase.from('tbl_complaint').update({
        'complaint_reply': reply,
        'complaint_status': 1,
      }).eq('complaint_id', complaintId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reply Posted Successfully"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      );

      replyController.clear();
      fetchComplaint(); // Refresh after reply
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      );
      print("Error in sending reply: $e");
    }
  }

  Future<void> showReplyDialog(int complaintId) async {
    replyController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // Reduced width
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Send Reply',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 3, 1, 68),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: replyController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            width: 3,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 3, 1, 68),
                          fontWeight: FontWeight.w900,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Reply';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 223, 53, 41),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 3, 1, 68),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await sendReply(complaintId);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Submit',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complaints')),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
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
                                showReplyDialog(data['complaint_id']);
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
