import 'package:admin_triveni/main.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeaverReportWidget extends StatefulWidget {
  const WeaverReportWidget({super.key});

  @override
  State<WeaverReportWidget> createState() => _WeaverReportWidgetState();
}

class _WeaverReportWidgetState extends State<WeaverReportWidget> {
  List<Map<String, dynamic>> bookings = [];
  Map<String, String> weaverNames = {};
  Map<String, int> weaverWorkCount = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch weaver names
      final weaverResponse =
          await supabase.from('tbl_weaver').select('weaver_id, weaver_name');
      setState(() {
        weaverNames = {
          for (var weaver in weaverResponse)
            weaver['weaver_id']: weaver['weaver_name']
        };
        print("Weaver Names: $weaverNames");
      });

      // Fetch bookings where weaver_id is not null
      final bookingResponse = await supabase
          .from('tbl_booking')
          .select('weaver_id')
          .not('weaver_id', 'is', null);

      // Aggregate work count per weaver
      Map<String, int> tempWorkCount = {};
      for (var booking in bookingResponse) {
        final weaverId = booking['weaver_id'];
        tempWorkCount[weaverId] = (tempWorkCount[weaverId] ?? 0) + 1;
      }

      setState(() {
        bookings = List<Map<String, dynamic>>.from(bookingResponse);
        weaverWorkCount = tempWorkCount;
        print("Weaver Work Count: $weaverWorkCount");
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
    if (weaverWorkCount.isEmpty) {
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
            "Weaver Work Report",
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
                maxY:
                    (weaverWorkCount.values.reduce((a, b) => a > b ? a : b) + 1)
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
                        final weaverId =
                            weaverWorkCount.keys.toList()[value.toInt()];
                        final name =
                            weaverNames[weaverId] ?? weaverId.substring(0, 6);
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
                      final weaverId = weaverWorkCount.keys.toList()[group.x];
                      final name = weaverNames[weaverId] ?? weaverId;
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
    final sortedKeys = weaverWorkCount.keys.toList()..sort();
    return sortedKeys.asMap().entries.map((entry) {
      final index = entry.key;
      final weaverId = entry.value;
      print(
          "Index: $index, Weaver: ${weaverNames[weaverId]}, Count: ${weaverWorkCount[weaverId]}");
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weaverWorkCount[weaverId]!.toDouble(),
            color: const Color.fromARGB(255, 27, 1, 69),
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();
  }
}
