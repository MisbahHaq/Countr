import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Load last 7 days
    for (int i = 0; i < 7; i++) {
      DateTime day = now.subtract(Duration(days: i));
      String key = "${day.year}-${day.month}-${day.day}";
      int seconds = prefs.getInt(key) ?? 0;
      tempData[key] = seconds;
    }

    setState(() {
      historyData = tempData;
    });
  }

  String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Focus History")),
      body: ListView(
        children: historyData.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: Text(formatTime(entry.value)),
          );
        }).toList(),
      ),
    );
  }
}
