import 'package:flutter/material.dart';
import 'package:user_triveni/main.dart';

class Viewdesign extends StatefulWidget {
  const Viewdesign({super.key});

  @override
  State<Viewdesign> createState() => _ViewdesignState();
}

class _ViewdesignState extends State<Viewdesign> {
  List<Map<String, dynamic>> designs = [];

  Future<void> fetchdesign() async {
    try {
      final response = await supabase.from('tbl_design').select();
      setState(() {
        designs = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdesign();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: .85, // Adjust card height vs width ratio
          ),
          itemBuilder: (context, index) {
            final data = designs[index];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                        image: DecorationImage(
                          image: NetworkImage(data['design_photo']),
                          fit: BoxFit.cover,
                        )),
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  Text(data['design_name']),
                ],
              ),
            );
          },
          itemCount: designs.length,
        ),
      ),
    );
  }
}
