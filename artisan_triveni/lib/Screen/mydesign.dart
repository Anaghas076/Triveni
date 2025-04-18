import 'package:artisan_triveni/Component/formvalidation.dart';
import 'package:artisan_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MyDesign extends StatefulWidget {
  const MyDesign({super.key});

  @override
  State<MyDesign> createState() => _MyDesignState();
}

class _MyDesignState extends State<MyDesign>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> designs = [];
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> fetchdesign() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });
    try {
      final response = await supabase
          .from('tbl_design')
          .select()
          .eq('artisan_id', supabase.auth.currentUser!.id);
      if (!mounted) return;

      setState(() {
        designs = response;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      // Error handling
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteDesign(int designId) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Delete Design'),
              content: Text('Are you sure you want to delete this design?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ) ??
          false;

      if (confirm) {
        setState(() {
          isLoading = true;
        });

        await supabase.from('tbl_design').delete().eq('design_id', designId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Design deleted successfully'),
            backgroundColor: Color.fromARGB(255, 3, 1, 68),
          ),
        );

        fetchdesign(); // Refresh the list
      }
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete design'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void openFullScreenView(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DesignGalleryView(
          designs: designs,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchdesign();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Must call super.build for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : designs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No designs found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first design by clicking the + button',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAddDesignDialog(context);
                        },
                        icon: Icon(Icons.add),
                        label: Text('Add Design'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 3, 1, 68),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchdesign,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: designs.length,
                      itemBuilder: (context, index) {
                        final data = designs[index];
                        return DesignCard(
                          design: data,
                          onTap: () => openFullScreenView(index),
                          onDelete: () => deleteDesign(data['design_id']),
                        );
                      },
                    ),
                  ),
                ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showAddDesignDialog(context);
      //   },
      //   backgroundColor: Color.fromARGB(255, 3, 1, 68),
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  // Method to show the add design dialog
  Future<void> _showAddDesignDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    File? selectedImage;
    bool isLoading = false;

    // Function to pick an image
    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
      }
    }

    // Function to upload image and save design
    Future<void> saveDesign() async {
      if (formKey.currentState!.validate() && selectedImage != null) {
        try {
          setState(() {
            isLoading = true;
          });

          // Upload image
          final timestamp = DateTime.now();
          final formattedDate =
              'Design-${timestamp.day}-${timestamp.month}-${timestamp.year}-${timestamp.hour}-${timestamp.minute}';

          await supabase.storage
              .from('design')
              .upload(formattedDate, selectedImage!);

          // Get public URL
          final imageUrl =
              supabase.storage.from('design').getPublicUrl(formattedDate);

          // Save to database
          await supabase.from('tbl_design').insert({
            'design_name': nameController.text,
            'design_photo': imageUrl,
            'artisan_id': supabase.auth.currentUser!.id,
          });

          // Refresh designs list
          fetchdesign();

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Design added successfully'),
                backgroundColor: Color.fromARGB(255, 3, 1, 68),
              ),
            );
          }

          // Close dialog
          Navigator.of(context).pop();
        } catch (e) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add design'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    }

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Add New Design',
              style: TextStyle(
                color: Color.fromARGB(255, 3, 1, 68),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image picker
                    GestureDetector(
                      onTap: () async {
                        await pickImage();
                        setDialogState(() {});
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(
                              26, 3, 1, 68), // 10% opacity (255 * 0.1 = ~26)
                          shape: BoxShape.circle,
                          image: selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: selectedImage == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Color.fromARGB(255, 3, 1, 68),
                                size: 40,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: nameController,
                      validator: (value) => FormValidation.validateName(value),
                      decoration: InputDecoration(
                        labelText: 'Design Name',
                        prefixIcon: Icon(Icons.design_services,
                            color: Color.fromARGB(255, 3, 1, 68)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color.fromARGB(255, 3, 1, 68)),
                        ),
                      ),
                    ),

                    // Error message for image
                    if (selectedImage == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please select an image',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () => saveDesign(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 3, 1, 68),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DesignCard extends StatelessWidget {
  final Map<String, dynamic> design;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DesignCard({
    super.key,
    required this.design,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Image container with tap gesture
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      image: design['design_photo'] != null
                          ? DecorationImage(
                              image: NetworkImage(design['design_photo']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: design['design_photo'] == null
                        ? Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              // Delete button
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(153),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  design['design_name'] ?? "No Name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.touch_app, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Tap to view',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DesignGalleryView extends StatefulWidget {
  final List<Map<String, dynamic>> designs;
  final int initialIndex;

  const DesignGalleryView({
    super.key,
    required this.designs,
    required this.initialIndex,
  });

  @override
  State<DesignGalleryView> createState() => _DesignGalleryViewState();
}

class _DesignGalleryViewState extends State<DesignGalleryView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(150),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.designs[_currentIndex]['design_name'] ?? 'Design View',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.designs[index]['design_photo']),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text('Failed to load image',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              );
            },
          );
        },
        itemCount: widget.designs.length,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(
              color: Colors.white,
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded /
                      (event.expectedTotalBytes ?? 1),
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
