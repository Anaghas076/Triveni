import 'package:flutter/material.dart';
import 'package:user_triveni/Component/formvalidation.dart';
import 'package:user_triveni/main.dart';

class Postcomplaint extends StatefulWidget {
  final int productId; // Complaint ID passed when opening this page

  const Postcomplaint({super.key, required this.productId});

  @override
  State<Postcomplaint> createState() => _PostcomplaintState();
}

class _PostcomplaintState extends State<Postcomplaint> {
  final TextEditingController titleContoller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> submit() async {
    try {
      String title = titleContoller.text;
      String description = descriptionController.text;

      await supabase.from('tbl_complaint').insert({
        'complaint_title': title,
        'complaint_description': description,
        'product_id': widget.productId,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Posted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      titleContoller.clear();
      descriptionController.clear();
    } catch (e) {
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
          "Post Complaint",
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
                    validator: (value) => FormValidation.validateTitle(value),
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
                    validator: (value) =>
                        FormValidation.validateDescription(value),
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
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
                      //   Icons.description,
                      //   color: const Color.fromARGB(255, 7, 2, 54),
                      // ),
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
                        if (formkey.currentState!.validate()) {
                          submit();
                        }
                      },
                      child: Text("Submit"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
