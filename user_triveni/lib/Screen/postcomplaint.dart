import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';

class Postcomplaint extends StatefulWidget {
  const Postcomplaint({super.key});

  @override
  State<Postcomplaint> createState() => _PostcomplaintState();
}

class _PostcomplaintState extends State<Postcomplaint> {
  final TextEditingController titleContoller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> submit() async {
    try {
      String design = titleContoller.text;
      String description = descriptionController.text;

      await supabase.from('tbl_Postcomplaintization').insert({
        'complaint_title': design,
        'complaint_description ': description,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      titleContoller.clear();
      descriptionController.clear();
    } catch (e) {
      print("Error Complaint: $e");
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
          "Post Complaint",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            TextFormField(
              controller: titleContoller,
              style: TextStyle(
                  color: const Color.fromARGB(255, 3, 1, 68),
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 10, 10, 10),
                    )),
                prefixIcon: Icon(
                  Icons.image,
                  color: const Color.fromARGB(255, 7, 2, 54),
                ),
                hintText: " Title",
                hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 8, 8, 8),
                    fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              style: TextStyle(
                  color: const Color.fromARGB(255, 3, 1, 68),
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 10, 10, 10),
                    )),
                prefixIcon: Icon(
                  Icons.description,
                  color: const Color.fromARGB(255, 7, 2, 54),
                ),
                hintText: " Description",
                hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 8, 8, 8),
                    fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  submit();
                },
                child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
