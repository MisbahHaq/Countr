import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, int> historyData = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, int> tempData = {};
    DateTime now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime day = now.subtract(Duration(days: i));
      String key = "${day.year}-${day.month}-${day.day}";
      int seconds = prefs.getInt(key) ?? 0;
      tempData[key] = seconds;
    }

    setState(() {
      historyData = Map.fromEntries(tempData.entries.toList().reversed);
    });
  }

  String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    List<String> days = historyData.keys.toList();
    List<int> values = historyData.values.toList();

    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        title: Text("Focus History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: historyData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(
                  height: 160,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: values.isNotEmpty
                            ? (values.reduce((a, b) => a > b ? a : b) / 3600 +
                                      1)
                                  .toDouble()
                            : 1,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= days.length) {
                                  return SizedBox.shrink();
                                }
                                String label = days[index]
                                    .split("-")
                                    .sublist(1)
                                    .join("/");
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    label,
                                    style: TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(days.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: values[index] / 3600,
                                color: Theme.of(context).primaryColor,
                                width: 14,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: historyData.entries.map((entry) {
                      return ListTile(
                        dense: true,
                        title: Text(entry.key),
                        trailing: Text(formatTime(entry.value)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
