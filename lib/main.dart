import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: FocusScreen());
  }
}

class FocusScreen extends StatefulWidget {
  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int seconds = 0;
  int dailyFocusSeconds = 0;
  int yesterdayFocusSeconds = 0;

  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    _loadFocusData();
  }

  Future<void> _loadFocusData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${now.month}-${now.day}";
    String yesterdayKey =
        "${now.subtract(const Duration(days: 1)).year}-${now.subtract(const Duration(days: 1)).month}-${now.subtract(const Duration(days: 1)).day}";

    setState(() {
      dailyFocusSeconds = prefs.getInt(todayKey) ?? 0;
      yesterdayFocusSeconds = prefs.getInt(yesterdayKey) ?? 0;
    });
  }

  Future<void> _saveFocusData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${now.month}-${now.day}";

    await prefs.setInt(todayKey, dailyFocusSeconds);
  }

  void startTimer() {
    timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (isRunning) {
        setState(() {
          seconds++;
          dailyFocusSeconds++;
        });
        _saveFocusData();
      }
    });
  }

  void toggleTimer() {
    setState(() {
      isRunning = !isRunning;
    });
    if (isRunning) {
      startTimer();
    }
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int secs = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    int focusDurationSeconds = 10800;
    double cappedProgress = (seconds / focusDurationSeconds).clamp(0.0, 1.0);

    Color bgColor = isRunning ? Colors.white : const Color(0xFFFF6F61);
    Color accentColor = isRunning ? Colors.redAccent : Colors.white;
    String modeLabel = isRunning ? "FOCUS" : "BREAK";

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Icon(Icons.settings, color: accentColor, size: 22),
              ),
            ),
            const Spacer(),
            CustomPaint(
              size: const Size(200, 200),
              painter: DottedArcPainter(cappedProgress, accentColor),
            ),
            const SizedBox(height: 20),
            if (isRunning)
              Text(
                "First round",
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            const SizedBox(height: 5),
            Text(
              formatTime(seconds),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w400,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                dot(true, accentColor),
                dot(false, Colors.grey[300]!),
                dot(false, Colors.grey[300]!),
                dot(false, Colors.grey[300]!),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              modeLabel,
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 2,
                color: isRunning ? Colors.grey : Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              "Today's Focus: ${formatTime(dailyFocusSeconds)}",
              style: TextStyle(color: accentColor, fontSize: 16),
            ),
            Text(
              "Yesterday's Focus: ${formatTime(yesterdayFocusSeconds)}",
              style: TextStyle(
                color: accentColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: toggleTimer,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRunning ? Colors.white : accentColor,
                  border: Border.all(color: accentColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isRunning ? Icons.pause : Icons.play_arrow,
                  color: isRunning ? accentColor : Colors.white,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget dot(bool active, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class DottedArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  DottedArcPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final totalDashes = 60; // Higher for smoother look
    final dashWidthAngle = (2 * pi) / (totalDashes * 1.4);
    final gapAngle = dashWidthAngle * 0.4;

    final paint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final filledDashes = (totalDashes * progress).floor();
    double startAngle = -pi / 2; // Start from top

    for (int i = 0; i < totalDashes; i++) {
      final isFilled = i < filledDashes;
      paint.color = isFilled ? color : Colors.grey[300]!;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashWidthAngle,
        false,
        paint,
      );
      startAngle += dashWidthAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
