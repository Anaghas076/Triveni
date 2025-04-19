import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Edit extends StatefulWidget {
  const Edit({super.key});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  Future<void> fetchartisan() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select()
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .single();

      setState(() {
        nameController.text = response['artisan_name'] ?? '';
        contactController.text = response['artisan_contact'] ?? '';
        addressController.text = response['artisan_address'] ?? '';
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> update() async {
    if (!formkey.currentState!.validate()) return;

    try {
      await supabase.from('tbl_artisan').update({
        'artisan_name': nameController.text,
        'artisan_contact': contactController.text,
        'artisan_address': addressController.text,
      }).eq('artisan_id', supabase.auth.currentUser!.id);

      Navigator.pop(context, true); // Return true to refresh profile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
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
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 3, 1, 68),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.edit_note,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "Name",
                                prefixIcon: Icon(Icons.person,
                                    color: Color.fromARGB(255, 54, 3, 116)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 3, 1, 68)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: contactController,
                              decoration: InputDecoration(
                                labelText: "Contact",
                                prefixIcon: Icon(Icons.phone,
                                    color: Color.fromARGB(255, 54, 3, 116)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 3, 1, 68)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your contact number';
                                }
                                // Regex for 10-digit contact number (you can modify this pattern for specific formats)
                                String pattern = r'^[0-9]{10}$';
                                RegExp regExp = RegExp(pattern);
                                if (!regExp.hasMatch(value)) {
                                  return 'Please enter a valid 10-digit contact number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: addressController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Address",
                                prefixIcon: Icon(Icons.location_on,
                                    color: Color.fromARGB(255, 54, 3, 116)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 3, 1, 68)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your address';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: update,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 3, 1, 68),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
