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
  List<Map<String, dynamic>> gallery = [];
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
      final bucketName = 'Gallery';
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
        SnackBar(content: Text('Pick an image first')),
      );
      return;
    }

    try {
      String? url = await photoUpload();
      if (url != null) {
        await supabase
            .from('tbl_Gallery')
            .insert({'Gallery_photo': url, 'product_id': widget.productid});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Photo Added"),
          backgroundColor: Colors.green,
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

  // Fetch Gallery Data
  Future<void> fetchGallery() async {
    try {
      final response = await supabase
          .from('tbl_Gallery')
          .select()
          .eq('product_id', widget.productid);
      ;
      setState(() {
        gallery = response;
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
      appBar: AppBar(title: Text("Gallery"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
                    ? Icon(Icons.add_a_photo, size: 50, color: Colors.blue)
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
              onPressed: submit,
              child: Text("Add Photo"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 30),
            // Gallery Grid
            Expanded(
              child: gallery.isEmpty
                  ? Center(child: Text("No Photos Available"))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: gallery.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            gallery[index]['Gallery_photo'],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
