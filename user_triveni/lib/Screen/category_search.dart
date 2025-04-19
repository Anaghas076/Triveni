import 'package:flutter/material.dart';
import 'package:user_triveni/component/formvalidation.dart';
import 'package:user_triveni/component/product_card.dart';
import 'package:user_triveni/main.dart';

class CategorySearch extends StatefulWidget {
  final int category;
  const CategorySearch({super.key, required this.category});

  @override
  State<CategorySearch> createState() => _CategorySearchState();
}

class _CategorySearchState extends State<CategorySearch> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  Future<void> fetchproduct() async {
    try {
      final response = await supabase
          .from('tbl_product')
          .select('*, tbl_subcategory!inner(*, tbl_category!inner(*))')
          .eq('tbl_subcategory.tbl_category.category_id', widget.category);

      print("Fetched products for category ${widget.category}: $response");
      List<Map<String, dynamic>> product = [];
      for (var items in response) {
        final response = await supabase
            .from('tbl_review')
            .select()
            .eq('product_id', items['product_id']);

        final reviewsList = List<Map<String, dynamic>>.from(response);

        // Calculate average rating
        double totalRating = 0;
        for (var review in reviewsList) {
          totalRating += double.parse(review['review_rating'].toString());
        }

        double avgRating =
            reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;
        items['rating'] = avgRating;
        product.add(items);
      }

      setState(() {
        products = List<Map<String, dynamic>>.from(product);
        filteredProducts = List.from(products);
      });
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchproduct();
    fetchsubcategory(widget.category
        .toString()); // Fetch subcategories for the selected category
    searchController.addListener(_filterProducts);
  }

  List<Map<String, dynamic>> subcategories = [];
  String? selectedSub;
  String selectedType = 'All';
  String selectedSize = 'All';

  Future<void> fetchsubcategory(String categoryId) async {
    try {
      final response = await supabase
          .from('tbl_subcategory')
          .select()
          .eq('category_id', categoryId);
      setState(() {
        subcategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error fetching subcategories: $e");
    }
  }

  void _filterProducts() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredProducts = products.where((product) {
        // Check if the query matches the product name or description
        bool matchesKeyword =
            product['product_name'].toString().toLowerCase().contains(query) ||
                product['product_description']
                    .toString()
                    .toLowerCase()
                    .contains(query);

        bool matchesSubcategory = selectedSub == null ||
            product['tbl_subcategory']['subcategory_id'].toString() ==
                selectedSub;

        bool matchesType =
            selectedType == 'All' || product['product_type'] == selectedType;

        bool matchesSize = selectedSize == 'All' ||
            (selectedSize == 'Free Size' && product['product_size'] == true) ||
            (selectedSize == 'No Size' && product['product_size'] == false);

        return matchesKeyword &&
            matchesSubcategory &&
            matchesType &&
            matchesSize;
      }).toList();
      print("Filtered products: $filteredProducts");
    });
  }

  void showFilter() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text(
                "Filter Options",
                style: TextStyle(color: Colors.yellowAccent),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subcategory Dropdown (only for the selected category)
                      DropdownButtonFormField(
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.greenAccent,
                        decoration: const InputDecoration(
                          fillColor: Color.fromARGB(255, 3, 1, 68),
                          filled: true,
                          labelText: "Select Subcategory",
                          labelStyle: TextStyle(color: Colors.yellowAccent),
                          border: OutlineInputBorder(),
                        ),
                        value: selectedSub,
                        items: subcategories.map((sub) {
                          return DropdownMenuItem(
                            value: sub['subcategory_id'].toString(),
                            child: Text(
                              sub['subcategory_name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          dialogSetState(() {
                            selectedSub = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // Type Selection
                      const Text(
                        "Type",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 20,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                activeColor: Colors.white,
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.grey),
                                value: "All",
                                groupValue: selectedType,
                                onChanged: (value) {
                                  dialogSetState(() {
                                    selectedType = value!;
                                  });
                                },
                              ),
                              const Text(
                                "All",
                                style: TextStyle(
                                    color: Colors.yellowAccent, fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                activeColor: Colors.white,
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.grey),
                                value: "Predesigned",
                                groupValue: selectedType,
                                onChanged: (value) {
                                  dialogSetState(() {
                                    selectedType = value!;
                                  });
                                },
                              ),
                              const Text(
                                "Predesigned",
                                style: TextStyle(
                                    color: Colors.yellowAccent, fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                activeColor: Colors.white,
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.grey),
                                value: "Customizable",
                                groupValue: selectedType,
                                onChanged: (value) {
                                  dialogSetState(() {
                                    selectedType = value!;
                                  });
                                },
                              ),
                              const Text(
                                "Customizable",
                                style: TextStyle(
                                    color: Colors.yellowAccent, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Size Selection
                      const Text(
                        "Size",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        spacing: 20,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                activeColor: Colors.white,
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.grey),
                                value: "All",
                                groupValue: selectedSize,
                                onChanged: (value) {
                                  dialogSetState(() {
                                    selectedSize = value!;
                                  });
                                },
                              ),
                              const Text(
                                "All",
                                style: TextStyle(
                                    color: Colors.yellowAccent, fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                activeColor: Colors.white,
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.grey),
                                value: "No Size",
                                groupValue: selectedSize,
                                onChanged: (value) {
                                  dialogSetState(() {
                                    selectedSize = value!;
                                  });
                                },
                              ),
                              const Text(
                                "No Size",
                                style: TextStyle(
                                    color: Colors.yellowAccent, fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                activeColor: Colors.white,
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.grey),
                                value: "Free Size",
                                groupValue: selectedSize,
                                onChanged: (value) {
                                  dialogSetState(() {
                                    selectedSize = value!;
                                  });
                                },
                              ),
                              const Text(
                                "Free Size",
                                style: TextStyle(
                                    color: Colors.yellowAccent, fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    dialogSetState(() {
                      selectedSub = null;
                      selectedType = "All";
                      selectedSize = "All";
                    });
                    _filterProducts();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _filterProducts();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Apply",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
              backgroundColor: const Color.fromARGB(255, 3, 1, 68),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          "Category-wise search",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Search by name or description",
                    suffixIcon: IconButton(
                      onPressed: () {
                        showFilter();
                      },
                      icon: const Icon(Icons.filter_alt_outlined),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: _getResponsiveAspectRatio(context),
                  ),
                  itemBuilder: (context, index) {
                    final data = filteredProducts[index];
                    return ProductCard(productData: data);
                  },
                  itemCount: filteredProducts.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getResponsiveAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // Example: Adjust ratio based on screen width and desired height
    return (screenWidth / 2) / (screenHeight * 0.45); // Customize as needed
  }
}
