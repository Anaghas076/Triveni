import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class District extends StatefulWidget {
  const District({super.key});

  @override
  State<District> createState() => _DistrictState();
}

class _DistrictState extends State<District> {
  final TextEditingController districtController = TextEditingController();
  List<Map<String, dynamic>> districts = [];

  Future<void> submit() async {
    try {
      String district = districtController.text;
      print(district);
      await supabase.from('tbl_district').insert({'district_name': district});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      districtController.clear();
      fetchDistrict();
    } catch (e) {
      print("Error district: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_district').delete().eq('district_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchDistrict();
    } catch (e) {}
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        districts = response;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
            child: ListView(
      padding: EdgeInsets.all(20),
      children: [
        TextFormField(
          controller: districtController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
              hintText: "Enter District Name",
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
          itemCount: districts.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final data = districts[index];
            return ListTile(
              leading: Text((index + 1).toString()),
              title: Text(data['district_name']),
              trailing: IconButton(
                  onPressed: () {
                    delete(data['district_id']);
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
