import 'package:flutter/material.dart';
import 'package:user_triveni/Component/formvalidation.dart';
import 'package:user_triveni/Component/product_card.dart';
import 'package:user_triveni/main.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = []; // Filtered list to display
  TextEditingController searchController = TextEditingController();

  Future<void> fetchproduct() async {
    try {
      final response = await supabase
          .from('tbl_product')
          .select("*, tbl_subcategory(*,tbl_category(*))");
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
        filteredProducts = List.from(products); // Initially show all products
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchproduct();
    fetchcategory();
    searchController.addListener(_filterProducts); // Listen to search input
  }

  List<Map<String, dynamic>> subcategories = [];
  List<Map<String, dynamic>> categories = [];

  String? selectedCat;
  String? selectedSub;
  String selectedType = 'All'; // Default to "All"
  String selectedSize = 'All'; // Default to "All"

  Future<void> fetchcategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchsubcategory(String id) async {
    try {
      final response =
          await supabase.from('tbl_subcategory').select().eq('category_id', id);
      setState(() {
        subcategories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  // Filter products based on search keyword and selected filters
  void _filterProducts() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        // Keyword search
        bool matchesKeyword =
            product['product_name'].toString().toLowerCase().contains(query) ||
                product['product_description']
                    .toString()
                    .toLowerCase()
                    .contains(query);

        // Category filter
        bool matchesCategory = selectedCat == null ||
            product['tbl_subcategory']['tbl_category']['category_id']
                    .toString() ==
                selectedCat;

        // Subcategory filter
        bool matchesSubcategory = selectedSub == null ||
            product['tbl_subcategory']['subcategory_id'].toString() ==
                selectedSub;

        // Type filter
        bool matchesType =
            selectedType == 'All' || product['product_type'] == selectedType;

        // Size filter
        bool matchesSize = selectedSize == 'All' ||
            (selectedSize == 'Free Size' && product['product_size'] == true) ||
            (selectedSize == 'No Size' && product['product_size'] == false);

        return matchesKeyword &&
            matchesCategory &&
            matchesSubcategory &&
            matchesType &&
            matchesSize;
      }).toList();
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
                      // Category Dropdown
                      DropdownButtonFormField(
                        validator: (value) =>
                            FormValidation.validateDropdown(value),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.green,
                        decoration: const InputDecoration(
                          fillColor: Color.fromARGB(255, 3, 1, 68),
                          filled: true,
                          labelText: "Select Category",
                          labelStyle: TextStyle(color: Colors.yellowAccent),
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCat,
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat['category_id'].toString(),
                            child: Text(
                              cat['category_name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          await fetchsubcategory(value!);
                          dialogSetState(() {
                            selectedCat = value;
                            selectedSub = null;
                          });
                        },
                      ),
                      const SizedBox(height: 15),

                      // Subcategory Dropdown
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
                      selectedCat = null;
                      selectedSub = null;
                      selectedType = "All";
                      selectedSize = "All";
                      subcategories = [];
                    });
                    _filterProducts(); // Apply reset filters
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Reset",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _filterProducts(); // Apply filters
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
    return SingleChildScrollView(
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.52,
              ),
              itemBuilder: (context, index) {
                final data = filteredProducts[index]; // Use filtered list

                return ProductCard(productData: products[index]);
              },
              itemCount: filteredProducts.length,
            ),
          ),
        ],
      ),
    );
  }
}
