import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';

class Homecontent extends StatefulWidget {
  const Homecontent({super.key});

  @override
  State<Homecontent> createState() => _HomecontentState();
}

class _HomecontentState extends State<Homecontent> {
  Map<String, dynamic> artisanid = {};
  int usercount = 0;
  int weavercount = 0;
  int artisancount = 0;
  int productcount = 0;
  int designcount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser();
    fetchWeaver();
    fetchArtisan();
    fetchDesign();
    fetchProduct();
    fetchName();
  }

  Future<void> fetchUser() async {
    try {
      final response = await supabase.from('tbl_user').count();
      setState(() {
        usercount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchProduct() async {
    try {
      final response = await supabase.from('tbl_product').count();
      setState(() {
        productcount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchArtisan() async {
    try {
      final response = await supabase.from('tbl_artisan').count();
      setState(() {
        artisancount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchName() async {
    try {
      final response = await supabase
          .from('tbl_artisan')
          .select('artisan_name')
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .single();
      setState(() {
        artisanid = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchWeaver() async {
    try {
      final response = await supabase.from('tbl_weaver').count();
      setState(() {
        weavercount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchDesign() async {
    try {
      final response = await supabase.from('tbl_design').count();
      setState(() {
        designcount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(5.0),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        children: [
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.architecture,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Hello ",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  artisanid['artisan_name'] ?? "Artisan Name",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.person,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Weaver",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  weavercount.toString(),
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.palette,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Artisan",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  artisancount.toString(),
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.people,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "User",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  usercount.toString(),
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Product",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  productcount.toString(),
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                Icon(
                  Icons.design_services,
                  color: const Color.fromARGB(255, 3, 1, 68),
                  size: 70,
                ),
                Text(
                  "Design",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  designcount.toString(),
                  style: TextStyle(
                      color: const Color.fromARGB(255, 3, 1, 68),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
