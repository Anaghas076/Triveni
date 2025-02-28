import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';

class Custom extends StatefulWidget {
  const Custom({super.key});

  @override
  State<Custom> createState() => _CustomState();
}

class _CustomState extends State<Custom> {
  final TextEditingController designController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> submit() async {
    try {
      String design = designController.text;
      String description = descriptionController.text;

      await supabase.from('tbl_customization').insert({
        'customization_design': design,
        'customization_description ': description,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      designController.clear();
      descriptionController.clear();
    } catch (e) {
      print("Error customization: $e");
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
          "Custom Order",
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
              controller: designController,
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
                hintText: " Design",
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
