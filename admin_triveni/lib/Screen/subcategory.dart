import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class Subcategory extends StatefulWidget {
  const Subcategory({super.key});

  @override
  State<Subcategory> createState() => _SubcategoryState();
}

class _SubcategoryState extends State<Subcategory> {
  final TextEditingController subcategoryController = TextEditingController();
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];
  String? selectedCat;

  Future<void> submit() async {
    try {
      String subcategory = subcategoryController.text;
      await supabase.from('tbl_subcategory').insert({
        'subcategory_name': subcategory,
        'category_id': selectedCat,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      subcategoryController.clear();
      setState(() {
        selectedCat = null;
      });
      fetchsubcategory();
    } catch (e) {
      print("Error subcategory: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_subcategory').delete().eq('subcategory_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchsubcategory();
    } catch (e) {
      print("Error: $e");
    }
  }

  int eid = 0;

  Future<void> update() async {
    try {
      await supabase.from('tbl_subcategory').update({
        'subcategory_name': subcategoryController.text,
        'category_id': selectedCat,
      }).eq('subcategory_id', eid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchcategory();
      fetchsubcategory();
      subcategoryController.clear();
      setState(() {
        eid = 0;
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> fetchsubcategory() async {
    try {
      final response =
          await supabase.from('tbl_subcategory').select(" * ,tbl_category(*)");
      setState(() {
        subcategories = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchcategory() async {
    try {
      print("Category");
      final response = await supabase.from('tbl_category').select();
      print(response);
      setState(() {
        categories = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchsubcategory();
    fetchcategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            DropdownButtonFormField(
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.green,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(255, 54, 3, 116),
                  filled: true,
                  labelText: "Select Category",
                  labelStyle: TextStyle(color: Colors.yellowAccent),
                ),
                value: selectedCat,
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    child: Text(
                      cat['category_name'],
                      style: TextStyle(),
                    ),
                    value: cat['category_id'].toString(),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCat = value;
                  });
                }),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: subcategoryController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  hintText: "Enter Subcategory Name",
                  hintStyle:
                      TextStyle(color: const Color.fromARGB(255, 248, 240, 10)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 54, 3, 116)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  if (eid == 0) {
                    submit();
                  } else {
                    update();
                  }
                },
                child: Text("Submit")),
            SizedBox(
              height: 50,
            ),
            ListView.builder(
              itemCount: subcategories.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = subcategories[index];
                return ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(data['subcategory_name']),
                  subtitle: Text(data['tbl_category']['category_name']),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              eid = data['subcategory_id'];
                              subcategoryController.text =
                                  data['subcategory_name'];
                              selectedCat = data['tbl_category']['category_id']
                                  .toString();
                            });
                          },
                          icon: Icon(Icons.edit),
                          color: const Color.fromARGB(255, 27, 1, 69),
                        ),
                        IconButton(
                          onPressed: () {
                            delete(data['subcategory_id']);
                          },
                          icon: Icon(Icons.delete),
                          color: const Color.fromARGB(255, 250, 34, 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
