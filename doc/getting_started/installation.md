# Installation Guide

This guide will help you install and set up the Deriv Chart library in your Flutter project.

## Requirements

Before installing the Deriv Chart library, ensure your project meets the following requirements:

- Dart SDK: >=3.0.0 <4.0.0
- Flutter: >=3.10.1

## Adding the Package

Add the Deriv Chart library to your project by including it in your `pubspec.yaml` file:

```yaml
dependencies:
  deriv_chart: ^0.3.7  # Replace with the latest version
```

Alternatively, you can use the Flutter CLI to add the package:

```bash
flutter pub add deriv_chart
```

## Importing the Library

After adding the package to your project, import it in your Dart files:

```dart
import 'package:deriv_chart/deriv_chart.dart';
```

## Verifying Installation

To verify that the library is correctly installed, you can create a simple chart:

```dart
import 'package:flutter/material.dart';
import 'package:deriv_chart/deriv_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Deriv Chart Example')),
        body: Center(
          child: SizedBox(
            height: 300,
            child: Chart(
              mainSeries: LineSeries([
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 5)), quote: 100),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 4)), quote: 120),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 3)), quote: 110),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 2)), quote: 130),
                Tick(epoch: DateTime.now().subtract(const Duration(minutes: 1)), quote: 125),
                Tick(epoch: DateTime.now(), quote: 140),
              ]),
              pipSize: 2,
            ),
          ),
        ),
      ),
    );
  }
}
```

## Dependencies

The Deriv Chart library depends on the following packages:

- deriv_technical_analysis: ^1.1.1
- provider: ^6.0.5
- shared_preferences: ^2.1.0
- intl: ^0.19.0

These dependencies are automatically installed when you add the Deriv Chart library to your project.

## Next Steps

Now that you have installed the Deriv Chart library, you can proceed to:

- [Basic Usage](basic_usage.md) - Learn how to create and customize charts
- [Chart Types](chart_types.md) - Explore different chart types available
- [Configuration](configuration.md) - Understand configuration options