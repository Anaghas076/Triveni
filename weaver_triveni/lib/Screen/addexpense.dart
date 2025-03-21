import 'package:weaver_triveni/Component/formvalidation.dart';
import 'package:flutter/material.dart';

import 'package:weaver_triveni/main.dart';
import 'package:weaver_triveni/main.dart';

class Addexpense extends StatefulWidget {
  const Addexpense({super.key});

  @override
  State<Addexpense> createState() => _AddexpenseState();
}

class _AddexpenseState extends State<Addexpense> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  List<Map<String, dynamic>> daily = [];

  Future<void> submit() async {
    try {
      String name = nameController.text;
      String amount = amountController.text;
      await supabase.from('tbl_daily').insert({
        'daily_name': name,
        'daily_amount': amount,
        'daily_type': "EXPENSE",
        'weaver_id': supabase.auth.currentUser!.id,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      amountController.clear();
      nameController.clear();
      fetchexpense();
    } catch (e) {
      print("Error daily: $e");
    }
  }

  Future<void> fetchexpense() async {
    try {
      final response = await supabase
          .from('tbl_daily')
          .select()
          .eq('weaver_id', supabase.auth.currentUser!.id);
      setState(() {
        daily = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_daily').delete().eq('daily_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchexpense();
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchexpense();
  }

  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                validator: (value) => FormValidation.validateName(value),
                controller: nameController,
                keyboardType: TextInputType.name,
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
                  hintText: " Name",
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
                validator: (value) => FormValidation.validateAmount(value),
                controller: amountController,
                keyboardType: TextInputType.number,
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
                  hintText: " Amount",
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
                  child: Text("Submit")),
              SizedBox(height: 10),
              Expanded(
                // Wrap ListView.builder inside Expanded
                child: daily.isEmpty
                    ? Center(child: Text("No expenses added"))
                    : ListView.builder(
                        itemCount: daily.length,
                        itemBuilder: (context, index) {
                          final data = daily[index];
                          return ListTile(
                            leading: Text((index + 1).toString()),
                            title: Text(
                              data['daily_name'] ?? "No Name",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 3, 1, 68),
                              ),
                            ),
                            subtitle: Text(
                              data['daily_amount'] ?? "No amount",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 3, 1, 68),
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                delete(data['daily_id']);
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
