import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> workData = [];
  List<Map<String, dynamic>> bookingData = [];
  Map<String, double> monthlyIncome = {};
  Map<String, double> monthlyExpense = {};
  Map<String, int> monthlyBookings = {};
  double totalIncome = 0;
  double totalExpense = 0;
  int totalBookings = 0;
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    await Future.wait([
      fetchWorkData(),
      fetchBookingData(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> fetchWorkData() async {
    try {
      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

      final response = await supabase
          .from('tbl_daily')
          .select()
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String())
          .order('created_at');

      setState(() {
        workData = response;
        processMonthlyData();
      });
    } catch (e) {
      print('Error fetching work data: $e');
    }
  }

  Future<void> fetchBookingData() async {
    try {
      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);

      final response = await supabase
          .from('tbl_booking')
          .select('''
            *,
            tbl_user(user_name),
            tbl_cart(
              cart_quantity,
              tbl_product(
                product_name,
                product_code,
                product_price
              )
            )
          ''')
          .eq('artisan_id', supabase.auth.currentUser!.id)
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String())
          .order('created_at');

      setState(() {
        bookingData = response;
        processBookingData();
      });
    } catch (e) {
      print('Error fetching booking data: $e');
    }
  }

  void processMonthlyData() {
    monthlyIncome.clear();
    monthlyExpense.clear();
    totalIncome = 0;
    totalExpense = 0;

    for (var transaction in workData) {
      final date = DateTime.parse(transaction['created_at']);
      final day = DateFormat('dd MMM').format(date);
      final amount = double.parse(transaction['daily_amount'].toString());

      if (transaction['daily_type'] == 'INCOME') {
        monthlyIncome[day] = (monthlyIncome[day] ?? 0) + amount;
        totalIncome += amount;
      } else {
        monthlyExpense[day] = (monthlyExpense[day] ?? 0) + amount;
        totalExpense += amount;
      }
    }
  }

  void processBookingData() {
    monthlyBookings.clear();
    totalBookings = bookingData.length;

    for (var booking in bookingData) {
      final date = DateTime.parse(booking['created_at']);
      final day = DateFormat('dd MMM').format(date);
      monthlyBookings[day] = (monthlyBookings[day] ?? 0) + 1;
    }
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
                'Monthly Report - ${DateFormat('MMMM yyyy').format(selectedDate)}',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            data: <List<String>>[
              ['Summary', 'Amount'],
              ['Total Income', 'Rs.${totalIncome.toStringAsFixed(2)}'],
              ['Total Expense', 'Rs.${totalExpense.toStringAsFixed(2)}'],
              ['Total Bookings', totalBookings.toString()],
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Header(
            level: 1,
            child: pw.Text('Booking Details',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ),
          ...bookingData
              .map((booking) => [
                    pw.Table.fromTextArray(
                      context: context,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      data: <List<String>>[
                        ['Date', 'Customer', 'Amount'],
                        [
                          DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(booking['created_at'])),
                          booking['tbl_user']['user_name'],
                          'Rs.${booking['booking_amount']}',
                        ],
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text('Products:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Table.fromTextArray(
                      context: context,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      data: <List<String>>[
                        ['Product Name', 'Product Code', 'Quantity', 'Price'],
                        ...(booking['tbl_cart'] as List).map((item) => [
                              item['tbl_product']['product_name'],
                              item['tbl_product']['product_code'],
                              item['cart_quantity'].toString(),
                              'Rs.${item['tbl_product']['product_price']}',
                            ]),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                  ])
              .expand((widgets) => widgets)
              .toList(),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/report_${DateFormat('MMM_yyyy').format(selectedDate)}.pdf');
    await file.writeAsBytes(await pdf.save());

    try {
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
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
        title: Text('Work Analysis',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                  fetchData();
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: generatePDF,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height -
                        MediaQuery.of(context).padding.top -
                        32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(selectedDate),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 3, 1, 68),
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildStatCards(),
                      SizedBox(height: 24),
                      _buildChartCard(),
                      SizedBox(height: 24),
                      _buildBookingsList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.2, // Adjust aspect ratio to give more height
      children: [
        _buildStatCard('Income', totalIncome, Colors.green),
        _buildStatCard('Expense', totalExpense, Colors.red),
        _buildStatCard('Bookings', totalBookings.toDouble(), Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String title, double value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(8), // Reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              // Wrap title in FittedBox
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 4), // Reduced spacing
            Expanded(
              // Wrap value in Expanded
              child: FittedBox(
                // Wrap value text in FittedBox
                fit: BoxFit.scaleDown,
                child: Text(
                  title == 'Bookings'
                      ? value.toInt().toString()
                      : '₹${value.toStringAsFixed(0)}', // Removed decimal places
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    Map<String, double> dailyProfitLoss = {};

    // Calculate daily profit/loss
    Set<String> allDays = {...monthlyIncome.keys, ...monthlyExpense.keys};
    for (String day in allDays) {
      double income = monthlyIncome[day] ?? 0;
      double expense = monthlyExpense[day] ?? 0;
      dailyProfitLoss[day] = income - expense;
    }

    // Sort days chronologically
    var sortedDays = dailyProfitLoss.keys.toList()
      ..sort((a, b) {
        var dateA = DateFormat('dd MMM').parse(a);
        var dateB = DateFormat('dd MMM').parse(b);
        return dateA.compareTo(dateB);
      });

    // Find max absolute value for scaling
    double maxValue = dailyProfitLoss.values.map((e) => e.abs()).reduce(max);

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profit/Loss Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: LineChart(
                LineChartData(
                  minY: -maxValue * 1.2, // Add 20% padding
                  maxY: maxValue * 1.2,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxValue / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: value == 0
                            ? Colors.black
                            : Colors.grey.withOpacity(0.3),
                        strokeWidth: value == 0 ? 2 : 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < sortedDays.length) {
                            // Show all days but rotate the text for better fit
                            return Transform.rotate(
                              angle: 0.785398, // 45 degrees in radians
                              child: Text(
                                sortedDays[index]
                                    .split(' ')[0], // Show only day number
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        interval: maxValue / 5, // Show 5 intervals
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                      left: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(sortedDays.length, (index) {
                        return FlSpot(
                          index.toDouble(),
                          dailyProfitLoss[sortedDays[index]]!,
                        );
                      }),
                      isCurved: false, // Straight lines between points
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          Color dotColor =
                              spot.y >= 0 ? Colors.green : Colors.red;
                          return FlDotCirclePainter(
                            radius: 5,
                            color: dotColor,
                            strokeWidth: 1,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final day = sortedDays[barSpot.x.toInt()];
                          final profitLoss = barSpot.y;
                          final isProfit = profitLoss >= 0;
                          return LineTooltipItem(
                            '$day\n${isProfit ? "Profit" : "Loss"}: ₹${profitLoss.abs().toStringAsFixed(0)}',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('Profit'),
                  ],
                ),
                SizedBox(width: 24),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('Loss'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Bookings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: bookingData.length,
              itemBuilder: (context, index) {
                final booking = bookingData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 3, 1, 68),
                    child: Text(
                      booking['tbl_user']['user_name'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(booking['tbl_user']['user_name']),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy').format(
                      DateTime.parse(booking['created_at']),
                    ),
                  ),
                  trailing: Text(
                    '₹${booking['booking_amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
