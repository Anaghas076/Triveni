import 'package:admin_triveni/Components/formvalidation.dart';
import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Reply extends StatefulWidget {
  const Reply({super.key});

  @override
  State<Reply> createState() => _PostcomplaintState();
}

class _PostcomplaintState extends State<Reply> {
  final TextEditingController replyContoller = TextEditingController();

  Future<void> reply() async {
    try {
      String reply = replyContoller.text;

      // Make sure to provide the correct complaint ID (replace 'complaint_id_value' accordingly)
      await supabase.from('tbl_complaint').update({
        'complaint_reply': reply,
        'complaint_status': 1,
      }); // Ensure you're updating the correct complaint

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Reply Posted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      replyContoller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
      print("Error Complaint: $e");
    }
  }

  final formkey = GlobalKey<FormState>();
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
          key: formkey,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color.fromARGB(255, 3, 1, 68),
                  width: 3,
                )),
            width: 340,
            height: 380,
            margin: EdgeInsets.only(top: 50),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) =>
                        FormValidation.validateDescription(value),
                    controller: replyContoller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 3, 1, 68),
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 10, 10, 10),
                          )),
                      // prefixIcon: Icon(
                      //   Icons.image,
                      //   color: const Color.fromARGB(255, 7, 2, 54),
                      // ),
                      hintText: " Reply",
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 8, 8, 8),
                          fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 500,
                    child: ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            reply();
                          }
                        },
                        child: Text("reply")),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
