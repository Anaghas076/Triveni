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
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
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
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
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

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      width: 3,
                    )),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validateName(value),
                        controller: nameController,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 3, 1, 68),
                                width: 3,
                              )),
                          prefixIcon: Icon(
                            Icons.description,
                            color: const Color.fromARGB(255, 7, 2, 54),
                          ),
                          hintText: "Name",
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        validator: (value) =>
                            FormValidation.validateAmount(value),
                        controller: amountController,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 3, 1, 68),
                                width: 3,
                              )),
                          prefixIcon: Icon(
                            Icons.money,
                            color: const Color.fromARGB(255, 7, 2, 54),
                          ),
                          hintText: "Amount",
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            fontWeight: FontWeight.w900,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 50),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            submit();
                          }
                        },
                        child: Text("Submit",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: daily.isEmpty
                    ? Center(
                        child: Text("No expenses added",
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: daily.length,
                        itemBuilder: (context, index) {
                          final data = daily[index];
                          return Card(
                            color: Colors.white,
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 3, 1, 68),
                                child: Text("${index + 1}",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              title: Text(data['daily_name'] ?? "No Name",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("₹${data['daily_amount'] ?? "0"}"),
                              trailing: IconButton(
                                onPressed: () => delete(data['daily_id']),
                                icon: Icon(Icons.delete, color: Colors.red),
                              ),
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
