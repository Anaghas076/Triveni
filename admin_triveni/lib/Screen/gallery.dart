import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:admin_triveni/main.dart';

class Gallery extends StatefulWidget {
  final int productid;
  const Gallery({super.key, required this.productid});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<Map<String, dynamic>> gallerys = [];
  PlatformFile? pickedImage;

  // Handle Image Selection
  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Single image selection
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  // Upload Image to Supabase Storage
  Future<String?> photoUpload() async {
    try {
      final bucketName = 'gallery';
      final filePath =
          "gallery-${DateTime.now().millisecondsSinceEpoch}-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!,
          );
      return supabase.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      print("Error uploading photo: $e");
      return null;
    }
  }

  // Submit Image
  Future<void> submit() async {
    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pick an image first'),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      );
      return;
    }

    try {
      String? url = await photoUpload();
      if (url != null) {
        await supabase
            .from('tbl_gallery')
            .insert({'gallery_photo': url, 'product_id': widget.productid});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Photo Added"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ));
        setState(() {
          pickedImage = null;
        });
        fetchGallery();
      }
    } catch (e) {
      print("Error adding photo: $e");
    }
  }

  Future<void> delete(int id) async {
    try {
      await supabase.from('tbl_gallery').delete().eq('gallery_id', id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Deleted"),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ));
      fetchGallery();
    } catch (e) {
      print("Error: $e");
    }
  }

  // Fetch Gallery Data
  Future<void> fetchGallery() async {
    try {
      final response = await supabase
          .from('tbl_gallery')
          .select()
          .eq('product_id', widget.productid);
      ;
      setState(() {
        gallerys = response;
      });
    } catch (e) {
      print("Error fetching gallery: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGallery();
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
            "View gallery",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Image Picker
              GestureDetector(
                onTap: handleImagePick,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: pickedImage == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: const Color.fromARGB(255, 3, 1, 68),
                        )
                      : ClipOval(
                          child: Image.memory(
                            Uint8List.fromList(pickedImage!.bytes!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                  ),
                  onPressed: () {
                    submit();
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  )),
              SizedBox(height: 30),
              Center(
                child: Container(
                  width: 300, // Adjust width as needed
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Gallery",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 54, 3, 116),
                        ),
                      ),
                      SizedBox(height: 10),
                      gallerys.isNotEmpty
                          ? ListView.builder(
                              itemCount: gallerys.length,
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // Prevent nested scrolling issues
                              itemBuilder: (context, index) {
                                final data = gallerys[index];
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          data['gallery_photo'] ?? ""),
                                    ),
                                    title: Text("Gallery Item ${index + 1}"),
                                    trailing: IconButton(
                                      onPressed: () {
                                        delete(data['gallery_id'] ?? "");
                                      },
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Text(
                              "No images available",
                              style: TextStyle(color: Colors.grey),
                            ),
                    ],
                  ),
                ),
              )
            ])));
  }
}
