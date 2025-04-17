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
      // Create some dummy data for testing
      Map<String, int> dummyWorkCount = {
        '86103f2c-d473-4e8c-819d-fec1a95f2916': 5, // Vani Naveen
        'fe8709e3-1efc-445a-b552-d12b093d493c': 3, // vami jay
        'b9b2d4fc-83e4-472c-a2c4-db0a46f32aa1': 7, // Veda Vikram
        '22903326-8e4b-4e7d-a1c7-5741274396e0': 2 // Vidhu Ram
      };

      // Fetch weaver names
      final weaverResponse =
          await supabase.from('tbl_weaver').select('weaver_id, weaver_name');

      setState(() {
        weaverNames = {
          for (var weaver in weaverResponse)
            weaver['weaver_id']: weaver['weaver_name']
        };

        // Use dummy data for now
        weaverWorkCount = dummyWorkCount;
      });
    } catch (e) {
      // Log error
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
        height: 500,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51), // 0.2 opacity = 51/255
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 450, // Increased height
      padding: const EdgeInsets.all(20.0), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51), // 0.2 opacity = 51/255
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
              color: const Color.fromARGB(255, 3, 1, 68),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: weaverWorkCount.isEmpty
                    ? 1.0
                    : (weaverWorkCount.values.reduce((a, b) => a > b ? a : b) +
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
                        try {
                          final sortedEntries = weaverWorkCount.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                          final sortedKeys =
                              sortedEntries.map((e) => e.key).toList();

                          if (value.toInt() >= 0 &&
                              value.toInt() < sortedKeys.length) {
                            final weaverId = sortedKeys[value.toInt()];
                            final name = weaverNames[weaverId] ??
                                (weaverId.length > 6
                                    ? weaverId.substring(0, 6)
                                    : weaverId);
                            return SideTitleWidget(
                              meta: meta,
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: Text(
                                  name,
                                  style: TextStyle(
                                      fontSize: 10), // Reduced font size
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(''),
                          );
                        } catch (e) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(''),
                          );
                        }
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
                      try {
                        final sortedEntries = weaverWorkCount.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        final sortedKeys =
                            sortedEntries.map((e) => e.key).toList();

                        if (group.x >= 0 && group.x < sortedKeys.length) {
                          final weaverId = sortedKeys[group.x];
                          final name = weaverNames[weaverId] ?? 'Unknown';
                          return BarTooltipItem(
                            '$name\nWorks: ${rod.toY.toInt()}',
                            TextStyle(color: Colors.white),
                          );
                        }
                        return null;
                      } catch (e) {
                        // Handle tooltip error
                        return null;
                      }
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
    if (weaverWorkCount.isEmpty) {
      return [];
    }

    try {
      // Sort by work count (highest first) instead of by key
      final sortedEntries = weaverWorkCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final sortedKeys = sortedEntries.map((e) => e.key).toList();

      return sortedKeys.asMap().entries.map((entry) {
        final index = entry.key;
        final weaverId = entry.value;
        final count = weaverWorkCount[weaverId] ?? 0;

        // Build bar for weaver
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: const Color.fromARGB(255, 3, 1, 68),
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        );
      }).toList();
    } catch (e) {
      // Handle bar group building error
      return [];
    }
  }
}
