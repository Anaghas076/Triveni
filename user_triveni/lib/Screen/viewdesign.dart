import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:user_triveni/main.dart';

class Viewdesign extends StatefulWidget {
  const Viewdesign({super.key});

  @override
  State<Viewdesign> createState() => _ViewdesignState();
}

class _ViewdesignState extends State<Viewdesign> {
  List<Map<String, dynamic>> designs = [];

  Future<void> fetchdesign() async {
    try {
      final response = await supabase.from('tbl_design').select();
      setState(() {
        designs = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching designs: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdesign();
  }

  Future<void> _saveImage(String imageUrl, String imageName) async {
    try {
      // Check and request storage permission based on Android version
      bool permissionGranted = false;

      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }

        if (status.isGranted) {
          permissionGranted = true;
        } else if (status.isPermanentlyDenied) {
          // Handle permanently denied by prompting user to enable in settings
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please enable storage permission in settings."),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      } else {
        // For iOS or other platforms, assume permission is not needed or handled differently
        permissionGranted = true;
      }

      if (permissionGranted) {
        // Use app-specific directory instead of external storage for broader compatibility
        Directory? directory = await getApplicationDocumentsDirectory();
        String savePath = "${directory.path}/$imageName.jpg";

        // Download image
        Dio dio = Dio();
        await dio.download(imageUrl, savePath);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image saved to $savePath")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Storage permission denied!")),
        );
      }
    } catch (e) {
      print("Error saving image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving image: $e")),
      );
    }
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
          "Designs",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: .75,
          ),
          itemBuilder: (context, index) {
            final data = designs[index];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(data['design_photo']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(data['design_name']),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 150,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 23, 2, 62),
                      ),
                      onPressed: () {
                        _saveImage(data['design_photo'], data['design_name']);
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          itemCount: designs.length,
        ),
      ),
    );
  }
}
