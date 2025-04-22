import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:deriv_chart/deriv_chart.dart';
import 'screens/home_screen.dart';

void main() {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ShowcaseApp());
}

/// The main application widget.
class ShowcaseApp extends StatelessWidget {
  /// Initialize the showcase app.
  const ShowcaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deriv Chart Showcase App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF85ACB0),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF85ACB0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        ChartLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      home: HomeScreen(),
    );
  }
}
