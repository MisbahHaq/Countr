import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  int seconds = 20 * 60; // 20 minutes
  Timer? timer;
  bool isRunning = true; // true = focus mode, false = break mode

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isRunning && seconds > 0) {
        setState(() {
          seconds--;
        });
      }
    });
  }

  void toggleTimer() {
    setState(() {
      isRunning = !isRunning;
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double progress = (seconds) / (20 * 60);

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
              painter: DottedArcPainter(progress, accentColor),
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
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    int totalDashes = 20;
    int filledDashes = (totalDashes * (1 - progress)).round();

    for (int i = 0; i < totalDashes; i++) {
      double angle = (pi / totalDashes) * i + pi;
      double startX = center.dx + radius * cos(angle);
      double startY = center.dy + radius * sin(angle);
      double endX = center.dx + (radius - 10) * cos(angle);
      double endY = center.dy + (radius - 10) * sin(angle);

      paint.color = i < filledDashes ? color : Colors.grey[300]!;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
