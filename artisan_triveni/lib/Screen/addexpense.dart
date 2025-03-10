import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Addexpense extends StatefulWidget {
  const Addexpense({super.key});

  @override
  State<Addexpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<Addexpense> {
  final TextEditingController expenseController = TextEditingController();
  List<Map<String, dynamic>> expenses = [];

  Future<void> submit() async {
    try {
      String expense = expenseController.text;

      await supabase.from('tbl_daily').insert({
        'daily_amount': expense,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Inserted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      expenseController.clear();
      fetchExpense();
    } catch (e) {
      print("Error Category: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_daily').delete().eq('daily_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchExpense();
    } catch (e) {
      print("Error: $e");
    }
  }

  int eid = 0;

  Future<void> update() async {
    try {
      await supabase.from('tbl_daily').update({
        'daily_amount': expenseController.text,
      }).eq('daily_id', eid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Updated"),
        backgroundColor: const Color.fromARGB(255, 54, 3, 116),
      ));
      fetchExpense();
      expenseController.clear();
      setState(() {
        eid = 0;
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> fetchExpense() async {
    try {
      final response = await supabase.from('tbl_daily').select();
      setState(() {
        expenses = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchExpense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: expenseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "Expense",
                  hintStyle:
                      TextStyle(color: const Color.fromARGB(255, 248, 240, 10)),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 54, 3, 116)),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: expenseController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "Expense",
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
              itemCount: expenses.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final data = expenses[index];
                return ListTile(
                  leading: Text((index + 1).toString()),
                  title: Text(data['daily_amount'] ?? ""),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              eid = data['category_id'];
                              expenseController.text =
                                  data['category_name'] ?? "";
                            });
                          },
                          icon: Icon(Icons.edit),
                          color: const Color.fromARGB(255, 27, 1, 69),
                        ),
                        IconButton(
                          onPressed: () {
                            delete(data['category_id']);
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
