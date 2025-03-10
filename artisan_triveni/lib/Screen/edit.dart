import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Edit extends StatefulWidget {
  const Edit({super.key});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  Future<void> fetchartisan() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select()
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        nameController.text = response['artisan_name'] ?? "";
        contactController.text = response['artisan_contact'] ?? "";
        addressController.text = response['artisan_address'] ?? "";
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> update() async {
    try {
      await supabase.from('tbl_artisan').update({
        'artisan_name': nameController.text,
        'artisan_contact': contactController.text,
        'artisan_address': addressController.text,
      }).eq('artisan_id', supabase.auth.currentUser!.id);

      Navigator.pop(context, true); // Return true to refresh profile
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchartisan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color.fromARGB(255, 3, 1, 68),
                width: 3,
              )),
          width: 350,
          height: 400,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.edit,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 80,
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: nameController,
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
                      Icons.person,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Artisan Name",
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
                  controller: addressController,
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
                      Icons.location_on,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Address",
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
                  controller: contactController,
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
                      Icons.phone,
                      color: const Color.fromARGB(255, 7, 2, 54),
                    ),
                    hintText: " Contact number",
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
                    update();
                  },
                  child: Text("Update"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
