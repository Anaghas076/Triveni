import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ArtisanPage extends StatefulWidget {
  const ArtisanPage({super.key});

  @override
  _ArtisanPageState createState() => _ArtisanPageState();
}

class _ArtisanPageState extends State<ArtisanPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> artisanData = [];
  Map<String, Map<String, double>> monthlyData = {};
  final dateFormat = DateFormat('dd MMM yyyy');
  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void initState() {
    super.initState();
    fetchArtisanData();
  }

  Future<void> fetchArtisanData() async {
    try {
      final response = await supabase
          .from('tbl_daily')
          .select()
          .not('artisan_id', 'is', null)
          .order('created_at', ascending: false);

      setState(() {
        artisanData = response;
        processMonthlyData();
        calculateTotals();
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void calculateTotals() {
    totalIncome = 0;
    totalExpense = 0;
    for (var item in artisanData) {
      final amount = double.parse(item['daily_amount'].toString());
      if (item['daily_type'] == 'INCOME') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }
  }

  void processMonthlyData() {
    monthlyData.clear();
    for (var item in artisanData) {
      final date = DateTime.parse(item['created_at'].toString());
      final monthKey = DateFormat('MMM yyyy').format(date);
      final amount = double.parse(item['daily_amount'].toString());

      monthlyData[monthKey] ??= {'INCOME': 0.0, 'EXPENSE': 0.0};
      monthlyData[monthKey]![item['daily_type']] =
          monthlyData[monthKey]![item['daily_type']]! + amount;
    }
  }

  Future<void> _showAddExpenseDialog() async {
    nameController.clear();
    amountController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Expense',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 3, 1, 68),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            width: 3,
                          )),
                      labelText: 'Description',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 3, 1, 68),
                        fontWeight: FontWeight.w900,
                      ),
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 3, 1, 68),
                        fontWeight: FontWeight.w900,
                      ),
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 3, 1, 68),
                            width: 3,
                          )),
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 3, 1, 68),
                        fontWeight: FontWeight.w900,
                      ),
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 3, 1, 68),
                        fontWeight: FontWeight.w900,
                      ),
                      prefixIcon: Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await submit();
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Submit',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> submit() async {
    try {
      String name = nameController.text;
      String amount = amountController.text;
      await supabase.from('tbl_daily').insert({
        'daily_name': name,
        'daily_amount': amount,
        'daily_type': "EXPENSE",
        'artisan_id': supabase.auth.currentUser!.id,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Expense added successfully"),
          backgroundColor: const Color.fromARGB(255, 3, 1, 68),
        ),
      );
      fetchArtisanData();
    } catch (e) {
      print("Error adding expense: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Financial Overview',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ),
      body: artisanData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchArtisanData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(),
                      SizedBox(height: 20),
                      _buildChart(),
                      SizedBox(height: 20),
                      _buildTransactionsList(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        label: Text(
          'Add Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 3, 1, 68),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: Icon(Icons.arrow_upward, color: Colors.green),
            ),
            title: Text(
              'Total Income',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              '₹${totalIncome.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red[100],
              child: Icon(Icons.arrow_downward, color: Colors.red),
            ),
            title: Text(
              'Total Expense',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              '₹${totalExpense.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.account_balance_wallet, color: Colors.blue),
            ),
            title: Text(
              'Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              '₹${(totalIncome - totalExpense).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Monthly Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: getBarGroups(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final month = monthlyData.keys.elementAt(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            month,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: artisanData.length,
          itemBuilder: (context, index) {
            final item = artisanData[index];
            final date = DateTime.parse(item['created_at'].toString());
            final formattedDate = dateFormat.format(date);
            final isIncome = item['daily_type'] == 'INCOME';

            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isIncome ? Colors.green[100] : Colors.red[100],
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  item['daily_name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(formattedDate),
                trailing: Text(
                  '${isIncome ? '+' : '-'}₹${item['daily_amount']}',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<BarChartGroupData> getBarGroups() {
    return monthlyData.entries.map((entry) {
      final index = monthlyData.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value['INCOME']!,
            color: Colors.green,
            width: 12,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
          ),
          BarChartRodData(
            toY: entry.value['EXPENSE']!,
            color: Colors.red,
            width: 12,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }
}
