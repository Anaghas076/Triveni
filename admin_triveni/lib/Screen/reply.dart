import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Reply extends StatefulWidget {
  final int complaintId; // Complaint ID passed when opening this page

  const Reply({super.key, required this.complaintId});

  @override
  State<Reply> createState() => _ReplyState();
}

class _ReplyState extends State<Reply> {
  final TextEditingController replyController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Future<void> sendReply() async {
    if (!formKey.currentState!.validate()) return;

    try {
      String reply = replyController.text.trim();

      if (widget.complaintId == 0) {
        throw "Invalid complaint ID";
      }

      // Update complaint_reply and complaint_status in tbl_complaint
      await supabase.from('tbl_complaint').update({
        'complaint_reply': reply,
        'complaint_status': 1, // Set status as replied
      }).eq('complaint_id',
          widget.complaintId); // Ensure correct complaint is updated

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reply Posted Successfully"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      );

      replyController.clear(); // Clear input field

      Navigator.pop(context); // Return to previous screen after posting reply
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
          "Send Reply",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color.fromARGB(255, 3, 1, 68),
                width: 3,
              ),
            ),
            width: 340,
            height: 380,
            margin: EdgeInsets.only(top: 50),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) => value == null || value.isEmpty
                        ? "Reply cannot be empty"
                        : null,
                    controller: replyController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 10, 10, 10),
                        ),
                      ),
                      hintText: "Enter Reply",
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 8, 8, 8),
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 500,
                    child: ElevatedButton(
                      onPressed: sendReply,
                      child: Text("Send Reply"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
