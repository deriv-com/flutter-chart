import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomPaint(
          painter: TestPath(),
        ),
      ),
    );
  }
}

class TestPath extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double topValue = 60;
    final double bottomValue = 62;
    final double middle = (topValue + bottomValue) / 2;

    final Path topRect = Path()..addRect(Rect.fromLTRB(-100, 0, 500, topValue));
    final Path bottomRect = Path()
      ..addRect(Rect.fromLTWH(0, bottomValue, 300, 300));

    final Path data = Path()
      ..moveTo(20, middle)
      ..lineTo(20, 10)
      ..lineTo(40, 80)
      ..lineTo(70, 20)
      ..lineTo(90, 80)
      ..lineTo(120, 20)
      ..lineTo(140, 90)
      ..lineTo(140, middle);

    final Path topFill = Path.combine(PathOperation.intersect, topRect, data);

    final Path bottomFill =
        Path.combine(PathOperation.intersect, bottomRect, data);

    final Paint fillPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas
      ..drawPath(topFill, fillPaint)
      ..drawPath(
          topRect, fillPaint..color = Colors.blueAccent.withOpacity(0.5));

    canvas.drawPath(data, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
