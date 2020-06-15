import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:deriv_flutter_chart/deriv_flutter_chart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Color(0xFF0E0E0E),
        child: SizedBox.expand(
          child: Chart(),
        ),
      ),
    );
  }
}
