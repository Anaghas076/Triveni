import 'package:admin_triveni/Components/formvalidation.dart';
import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class Attribute extends StatefulWidget {
  const Attribute({super.key});

  @override
  State<Attribute> createState() => _AttributeState();
}

class _AttributeState extends State<Attribute> {
  final TextEditingController attributeController = TextEditingController();
  List<Map<String, dynamic>> attributes = [];
  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];
  String? selectedCat;
  String? selectedSub;

  Future<void> submit() async {
    try {
      String attribute = attributeController.text;
      print(attribute);
      await supabase.from('tbl_attribute').insert({
        'attribute_name': attribute,
        'subcategory_id': selectedSub,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      attributeController.clear();
      fetchattribute();
      setState(() {
        selectedCat = null;
        selectedSub = null;
      });
    } catch (e) {
      print("Error Attribute: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_attribute').delete().eq('attribute_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchattribute();
    } catch (e) {
      print("Error : $e");
    }
  }

  //int eid = 0;

  //Future<void> update() async {
  // try {
  // await supabase.from('tbl_attribute').update({
  // 'attribute_name': attributeController.text,
  //'category_id': selectedCat,
  //'subcategory_id': selectedSub,
  //}).eq('attribute_id', eid);
  //ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //content: Text("Updated"),
  // backgroundColor: const Color.fromARGB(255, 54, 3, 116),
  // ));
  // fetchcategory();
  // fetchsubcategory();
  //fetchattribute();
  //attributeController.clear();
  //setState(() {
  //eid = 0;
  //});
  //} catch (e) {
  // print("Error updating data: $e");
  // }
  // }

  Future<void> fetchattribute() async {
    try {
      final response =
          await supabase.from('tbl_attribute').select(" * ,tbl_subcategory(*)");
      setState(() {
        attributes = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchsubcategory(String id) async {
    try {
      print("Subcategory");
      final response =
          await supabase.from('tbl_subcategory').select().eq('category_id', id);
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
    fetchcategory();
    fetchattribute();
  }

  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            DropdownButtonFormField(
                validator: (value) => FormValidation.validateDropdown(value),
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.green,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(255, 54, 3, 116),
                  filled: true,
                  labelText: "Select category",
                  labelStyle: TextStyle(color: Colors.yellowAccent),
                ),
                value: selectedCat,
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat['category_id'].toString(),
                    child: Text(
                      cat['category_name'],
                      style: TextStyle(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  fetchsubcategory(value!);
                  setState(() {
                    selectedCat = value;
                  });
                }),
            SizedBox(
              height: 20,
            ),
            DropdownButtonFormField(
                validator: (value) => FormValidation.validateDropdown(value),
                style: TextStyle(color: Colors.white),
                dropdownColor: Colors.greenAccent,
                decoration: InputDecoration(
                    fillColor: const Color.fromARGB(255, 54, 3, 116),
                    filled: true,
                    labelText: "Select Subcategory",
                    labelStyle: TextStyle(color: Colors.yellowAccent)),
                value: selectedSub,
                items: subcategories.map((sub) {
                  return DropdownMenuItem(
                    value: sub['subcategory_id'].toString(),
                    child: Text(
                      sub['subcategory_name'],
                      style: TextStyle(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSub = value;
                  });
                }),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: (value) => FormValidation.validatAttribute(value),
              style: TextStyle(color: Colors.white),
              controller: attributeController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  hintText: "Enter Attribute Name",
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
                  if (formkey.currentState!.validate()) {
                    //  if (eid == 0) {
                    submit();
                    //   } else {
                    //update();
                    // }
                  }
                },
                child: Text("Submit")),
            SizedBox(
              height: 50,
            ),
            ListView.builder(
              itemCount: attributes.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = attributes[index];
                return ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(data['attribute_name']),
                  subtitle: Text(data['tbl_subcategory']['subcategory_name']),
                  trailing: //SizedBox(
                      // width: 80,
                      //child: Row(
                      //children: [
                      // IconButton(
                      // onPressed: () {
                      // setState(() {
                      //eid = data['attribute_id'];
                      //attributeController.text = data['attribute_name'];
                      //selectedCat = data['tbl_category']['category_id']
                      //  .toString();
                      //selectedSub = data['tbl_subcategory']
                      //      ['subcategory_id']
                      //    .toString();
                      //});
                      //},
                      //  icon: Icon(Icons.edit),
                      //  color: const Color.fromARGB(255, 27, 1, 69),
                      // ),
                      IconButton(
                    onPressed: () {
                      delete(data['attribute_id']);
                    },
                    icon: Icon(Icons.delete),
                    color: const Color.fromARGB(255, 250, 34, 10),
                    // ),
                    // ],
                  ),
                  // ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
