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
  Map<String, String> weaverNames = {}; // Maps weaver_id to weaver_name
  Map<String, int> weaverWorkCount = {}; // Maps weaver_id to work count

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
      });

      // Fetch bookings where weaver_id is not null
      final bookingResponse = await supabase
          .from('tbl_booking')
          .select('weaver_id')
          .not('weaver_id', 'is', null); // Exclude bookings without weaver_id

      // Aggregate work count per weaver
      Map<String, int> tempWorkCount = {};
      for (var booking in bookingResponse) {
        final weaverId = booking['weaver_id'];
        tempWorkCount[weaverId] = (tempWorkCount[weaverId] ?? 0) + 1;
      }

      setState(() {
        bookings = List<Map<String, dynamic>>.from(bookingResponse);
        weaverWorkCount = tempWorkCount;
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
        height: 300, // Fixed height for dashboard
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
      height: 300, // Fixed height for dashboard
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weaver Work Report",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
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
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        final weaverId =
                            weaverWorkCount.keys.toList()[value.toInt()];
                        final name =
                            weaverNames[weaverId] ?? weaverId.substring(0, 8);
                        return SideTitleWidget(
                          meta: meta, // Required meta parameter
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              name,
                              style: TextStyle(fontSize: 12),
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
                borderData: FlBorderData(border: Border()),
                gridData: FlGridData(
                  show: true, // Enable grid
                  drawHorizontalLine: true, // Show horizontal grid lines
                  drawVerticalLine: false, // Hide vertical grid lines
                  horizontalInterval:
                      1, // Interval for horizontal lines (optional)
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
    return weaverWorkCount.entries.map((entry) {
      final index = weaverWorkCount.keys.toList().indexOf(entry.key);
      print(index);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blueAccent,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}
