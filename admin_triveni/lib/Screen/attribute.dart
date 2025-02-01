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
      fetchAttribute();
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
      fetchAttribute();
    } catch (e) {}
  }

  Future<void> fetchAttribute() async {
    try {
      final response =
          await supabase.from('tbl_attribute').select(" * ,tbl_subcategory(*)");
      setState(() {
        attributes = response;
      });
    } catch (e) {}
  }

  Future<void> fetchsubcategory(String id) async {
    try {
      print("Subcategory");
      final response =
          await supabase.from('tbl_subcategory').select().eq('category_id', id);
      setState(() {
        subcategories = response;
      });
    } catch (e) {}
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
    fetchAttribute();
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
              labelText: "Select category",
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
              fetchsubcategory(value!);
              setState(() {
                selectedCat = value;
              });
            }),
        SizedBox(
          height: 20,
        ),
        DropdownButtonFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                fillColor: const Color.fromARGB(255, 54, 3, 116),
                filled: true,
                labelText: "Select Subcategory",
                labelStyle: TextStyle(color: Colors.yellowAccent)),
            value: selectedSub,
            items: subcategories.map((sub) {
              return DropdownMenuItem(
                child: Text(
                  sub['subcategory_name'],
                  style: TextStyle(),
                ),
                value: sub['subcategory_id'].toString(),
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
              submit();
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
              trailing: IconButton(
                  onPressed: () {
                    delete(data['attribute_id']);
                  },
                  icon: Icon(Icons.delete,
                      color: const Color.fromARGB(255, 255, 21, 0))),
            );
          },
        )
      ],
    )));
  }
}
