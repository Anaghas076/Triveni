import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';

class Postcomplaint extends StatefulWidget {
  const Postcomplaint({super.key});

  @override
  State<Postcomplaint> createState() => _PostcomplaintState();
}

class _PostcomplaintState extends State<Postcomplaint> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> submit() async {
    try {
      String title = titleController.text;
      String description = descriptionController.text;

      await supabase.from('tbl_complaint').insert({
        'complaint_title': title,
        'complaint_description ': description,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      titleController.clear();
      descriptionController.clear();
    } catch (e) {
      print("Error Complaint: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Post Complaint",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Text("Post Complaint"),
      ),
    );
  }
}
