import 'package:flutter/material.dart';
import 'package:admin_triveni/main.dart';

class Arejectedlist extends StatefulWidget {
  const Arejectedlist({super.key});

  @override
  State<Arejectedlist> createState() => _ArejectedlistState();
}

class _ArejectedlistState extends State<Arejectedlist> {
  List<Map<String, dynamic>> artisans = [];

  Future<void> fetchartisan() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select()
          .eq('artisan_status', 2)
          .order('created_at', ascending: true);

      setState(() {
        artisans = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching artisans: $e");
    }
  }

  Future<void> updateartisanStatus(String artisanId, int status) async {
    try {
      await supabase
          .from('tbl_artisan')
          .update({'artisan_status': status}).eq('artisan_id', artisanId);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Artisan Accepted"),
        backgroundColor: const Color.fromARGB(255, 27, 1, 69),
      ));

      fetchartisan(); // Refresh the list
    } catch (e) {
      print("Error updating status: $e");
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
      body: artisans.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: .85,
              ),
              itemCount: artisans.length,
              itemBuilder: (context, index) {
                final data = artisans[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(data['artisan_photo'] ?? ""),
                            backgroundColor: Colors.grey.shade200,
                          ),
                          SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['artisan_name'] ?? " ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(data['artisan_address'] ?? " "),
                                Text(data['artisan_contact'] ?? " "),
                                Text(data['artisan_email'] ?? " "),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data['artisan_proof'] ?? "",
                          width: 150,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () {
                          updateartisanStatus(data['artisan_id'].toString(), 1);
                        },
                        child: Text("Accept"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
