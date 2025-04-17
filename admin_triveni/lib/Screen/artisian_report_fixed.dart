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
      // Create some dummy data for testing
      Map<String, int> dummyWorkCount = {
        '21e7d0e2-c421-4ac8-a8f5-d133a3bdc521': 6, // Amy Dev
        '71c675a3-9e51-4eba-9c47-23cb424938eb': 4, // Arav Ravi
        '7dbc4c25-fbe9-47c9-86b1-c7739a3612bd': 8, // Abin Raj
        'ac9c3835-1f59-40f9-b6ab-811293233ab1': 3 // Ayan Raj
      };

      // Fetch artisan names
      final artisanResponse =
          await supabase.from('tbl_artisan').select('artisan_id, artisan_name');

      setState(() {
        artisanNames = {
          for (var artisan in artisanResponse)
            artisan['artisan_id']: artisan['artisan_name']
        };

        // Use dummy data for now
        artisanWorkCount = dummyWorkCount;
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
    if (artisanWorkCount.isEmpty) {
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
            "Artisan Work Report",
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
                maxY: artisanWorkCount.isEmpty
                    ? 1.0
                    : (artisanWorkCount.values.reduce((a, b) => a > b ? a : b) +
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
                          final sortedEntries = artisanWorkCount.entries
                              .toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                          final sortedKeys =
                              sortedEntries.map((e) => e.key).toList();

                          if (value.toInt() >= 0 &&
                              value.toInt() < sortedKeys.length) {
                            final artisanId = sortedKeys[value.toInt()];
                            final name = artisanNames[artisanId] ??
                                (artisanId.length > 6
                                    ? artisanId.substring(0, 6)
                                    : artisanId);
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
                        final sortedEntries = artisanWorkCount.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        final sortedKeys =
                            sortedEntries.map((e) => e.key).toList();

                        if (group.x >= 0 && group.x < sortedKeys.length) {
                          final artisanId = sortedKeys[group.x];
                          final name = artisanNames[artisanId] ?? 'Unknown';
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
    if (artisanWorkCount.isEmpty) {
      return [];
    }

    try {
      // Sort by work count (highest first) instead of by key
      final sortedEntries = artisanWorkCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final sortedKeys = sortedEntries.map((e) => e.key).toList();

      return sortedKeys.asMap().entries.map((entry) {
        final index = entry.key;
        final artisanId = entry.value;
        final count = artisanWorkCount[artisanId] ?? 0;

        // Build bar for artisan
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
