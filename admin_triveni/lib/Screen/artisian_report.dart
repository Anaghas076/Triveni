import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ArtisanReportWidget extends StatefulWidget {
  const ArtisanReportWidget({super.key});

  @override
  State<ArtisanReportWidget> createState() => _ArtisanReportWidgetState();
}

class _ArtisanReportWidgetState extends State<ArtisanReportWidget> {
  List<Map<String, dynamic>> bookings = [];
  Map<String, String> artisanNames = {};
  Map<String, int> artisanWorkCount = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch artisan names
      final artisanResponse =
          await supabase.from('tbl_artisan').select('artisan_id, artisan_name');
      setState(() {
        artisanNames = {
          for (var artisan in artisanResponse)
            artisan['artisan_id']: artisan['artisan_name']
        };
        print("artisan Names: $artisanNames");
      });

      // Fetch bookings where artisan_id is not null
      final bookingResponse = await supabase
          .from('tbl_booking')
          .select('artisan_id')
          .not('artisan_id', 'is', null);

      // Aggregate work count per artisan
      Map<String, int> tempWorkCount = {};
      for (var booking in bookingResponse) {
        final artisanId = booking['artisan_id'];
        tempWorkCount[artisanId] = (tempWorkCount[artisanId] ?? 0) + 1;
      }

      setState(() {
        bookings = List<Map<String, dynamic>>.from(bookingResponse);
        artisanWorkCount = tempWorkCount;
        print("artisan Work Count: $artisanWorkCount");
      });
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (artisanWorkCount.isEmpty) {
      return Container(
        height: 300,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 350, // Increased height
      padding: const EdgeInsets.all(20.0), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Artisan Work Report",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 27, 1, 69),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (artisanWorkCount.values.reduce((a, b) => a > b ? a : b) +
                        1)
                    .toDouble(),
                barGroups: _buildBarGroups(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80, // Increased space for labels
                      getTitlesWidget: (value, meta) {
                        final artisanId =
                            artisanWorkCount.keys.toList()[value.toInt()];
                        final name = artisanNames[artisanId] ??
                            artisanId.substring(0, 6);
                        return SideTitleWidget(
                          meta: meta,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              name,
                              style:
                                  TextStyle(fontSize: 10), // Reduced font size
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                    border: Border(
                  left: BorderSide(color: Colors.black, width: 1),
                  bottom: BorderSide(color: Colors.black, width: 1),
                )),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final artisanId = artisanWorkCount.keys.toList()[group.x];
                      final name = artisanNames[artisanId] ?? artisanId;
                      return BarTooltipItem(
                        '$name\nWorks: ${rod.toY.toInt()}',
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final sortedKeys = artisanWorkCount.keys.toList()..sort();
    return sortedKeys.asMap().entries.map((entry) {
      final index = entry.key;
      final artisanId = entry.value;
      print(
          "Index: $index, artisan: ${artisanNames[artisanId]}, Count: ${artisanWorkCount[artisanId]}");
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: artisanWorkCount[artisanId]!.toDouble(),
            color: const Color.fromARGB(255, 27, 1, 69),
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();
  }
}
