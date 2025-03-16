import 'package:artisan_triveni/Screen/adddesign.dart';
import 'package:artisan_triveni/Screen/addexpense.dart';
import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: .85,
                    ),
                    itemCount: designs.length,
                    itemBuilder: (context, index) {
                      final data = designs[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                image: data['design_photo'] != null
                                    ? DecorationImage(
                                        image:
                                            NetworkImage(data['design_photo']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(height: 9),
                            Text(data['design_name'] ?? "No Name"),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Add Expense Button (Bottom-Left)
          Positioned(
            bottom: 20,
            left: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 3, 1, 68),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Addexpense()),
                  );
                },
                child: Text(
                  "Add Expense",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          // Floating Action Button (Bottom-Right)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDesign()),
                );
              },
              backgroundColor: Color.fromARGB(255, 3, 1, 68),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
