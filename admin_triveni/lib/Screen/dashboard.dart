import 'package:admin_triveni/screen/artisian_report.dart';
import 'package:admin_triveni/screen/weaver_report.dart';
import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic> adminid = {};

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
    fetchAdmin();
  }

  Future<void> fetchAdmin() async {
    try {
      print(supabase.auth.currentUser!.id);
      final response = await supabase
          .from('tbl_admin')
          .select('admin_name')
          .eq('id', supabase.auth.currentUser!.id)
          .maybeSingle()
          .limit(1);

      print(response);
      setState(() {
        adminid = response!;
      });
    } catch (e) {
      print("Error fetching admin data: $e");
    }
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
      final response =
          await supabase.from('tbl_artisan').count().eq('artisan_status', 1);
      setState(() {
        artisancount = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchWeaver() async {
    try {
      final response =
          await supabase.from('tbl_weaver').count().eq('weaver_status', 1);
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
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          GridView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            children: [
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
                      adminid['admin_name'] ?? " ",
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
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Expanded(child: WeaverReportWidget()),
              SizedBox(
                width: 20,
              ),
              Expanded(child: ArtisanReportWidget()),
            ],
          ),
         
        ],
      ),
    ));
  }
}
