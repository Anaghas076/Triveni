import 'package:artisan_triveni/Screen/adddesign.dart';
import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Viewdesign extends StatefulWidget {
  const Viewdesign({super.key});

  @override
  State<Viewdesign> createState() => _ViewdesignState();
}

class _ViewdesignState extends State<Viewdesign> {
  List<Map<String, dynamic>> designs = [];

  Future<void> fetchdesign() async {
    try {
      final response = await supabase.from('tbl_design');
      setState(() {
        designs = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_design').delete().eq('design_id', id);
      fetchdesign();
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10, // Space between columns
          mainAxisSpacing: 10, // Space between rows
          childAspectRatio: .7, // Adjust card height vs width ratio
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
                Image.network(data['design_photo'], fit: BoxFit.scaleDown),
                Text(data['design_description']),
              ],
            ),
          );
        },
        itemCount: designs.length,
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDesign(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      ),
    );
  }
}
