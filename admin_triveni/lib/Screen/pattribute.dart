import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class Pattribute extends StatefulWidget {
  const Pattribute({super.key});

  @override
  State<Pattribute> createState() => _PattributeState();
}

class _PattributeState extends State<Pattribute> {
  final TextEditingController pattributeController = TextEditingController();
  List<Map<String, dynamic>> pattributes = [];
  List<Map<String, dynamic>> attributes = [];
  String? selectedAtt;

  Future<void> submit() async {
    try {
      String pattribute = pattributeController.text;
      await supabase.from('tbl_pattribute').insert({
        'pattribute_name': pattribute,
        'attribute_id': selectedAtt,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      pattributeController.clear();
      fetchpattribute();
      setState(() {
        selectedAtt = null;
      });
    } catch (e) {
      print("Error pattribute: $e");
    }
  }

  Future<void> fetchpattribute() async {
    try {
      final response =
          await supabase.from('tbl_pattribute').select(" * ,tbl_attribute(*)");
      setState(() {
        pattributes = response;
      });
    } catch (e) {}
  }

  Future<void> fetchattribute() async {
    try {
      print("Attribute");
      final response = await supabase.from('tbl_attribute').select();
      print(response);
      setState(() {
        attributes = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_pattribute').delete().eq('pattribute_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchpattribute();
    } catch (e) {}
  }

  int eid = 0;

  Future<void> update() async {
    try {
      await supabase.from('tbl_pattribute').update({
        'pattribute_name': pattributeController.text,
        'attribute_id': selectedAtt,
      }).eq('pattribute_id', eid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchattribute();
      fetchpattribute();
      pattributeController.clear();
      setState(() {
        eid = 0;
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchpattribute();
    fetchattribute();
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
                  labelText: "Select Attribute",
                  labelStyle: TextStyle(color: Colors.yellowAccent),
                ),
                value: selectedAtt,
                items: attributes.map((att) {
                  return DropdownMenuItem(
                    child: Text(
                      att['attribute_name'],
                      style: TextStyle(),
                    ),
                    value: att['attribute_id'].toString(),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAtt = value;
                  });
                }),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: pattributeController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  hintText: "Enter pattribute Name",
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
              itemCount: pattributes.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = pattributes[index];
                return ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(data['pattribute_name']),
                  subtitle: Text(data['tbl_attribute']['attribute_name']),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              eid = data['pattribute_id'];
                              pattributeController.text =
                                  data['pattribute_name'];
                              selectedAtt = data['tbl_attribute']
                                      ['attribute_id']
                                  .toString();
                            });
                          },
                          icon: Icon(Icons.edit),
                          color: const Color.fromARGB(255, 27, 1, 69),
                        ),
                        IconButton(
                          onPressed: () {
                            delete(data['pattribute_id']);
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
