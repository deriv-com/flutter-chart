# Custom Themes

This document explains how to create and use custom themes in the Deriv Chart library to customize the appearance of your charts.

## Introduction to Chart Themes

The Deriv Chart library uses themes to control the visual appearance of charts. Themes define colors, styles, and other visual properties for various chart elements, such as:

- Background colors
- Grid lines and labels
- Crosshair appearance
- Default series styles
- Annotation styles

The library provides default light and dark themes, but you can create custom themes to match your application's design.

## Default Themes

The Deriv Chart library includes two default themes:

1. **ChartDefaultLightTheme**: A light theme with a white background and dark text
2. **ChartDefaultDarkTheme**: A dark theme with a dark background and light text

By default, the chart automatically uses the appropriate theme based on the application's brightness:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  // Theme is automatically selected based on Theme.of(context).brightness
)
```

You can explicitly specify a theme:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  theme: ChartDefaultDarkTheme(),
)
```

## Creating a Custom Theme

There are two approaches to creating a custom theme:

1. **Extending a default theme**: Override specific properties of a default theme
2. **Implementing the ChartTheme interface**: Create a completely custom theme

### Extending a Default Theme

The easiest way to create a custom theme is to extend one of the default themes and override specific properties:

```dart
class CustomDarkTheme extends ChartDefaultDarkTheme {
  @override
  GridStyle get gridStyle => GridStyle(
    gridLineColor: Colors.yellow,
    xLabelStyle: textStyle(
      textStyle: caption2,
      color: Colors.yellow,
      fontSize: 13,
    ),
    yLabelStyle: textStyle(
      textStyle: caption2,
      color: Colors.yellow,
      fontSize: 13,
    ),
  );
  
  @override
  CrosshairStyle get crosshairStyle => CrosshairStyle(
    lineColor: Colors.orange,
    labelBackgroundColor: Colors.orange.withOpacity(0.8),
    labelTextStyle: textStyle(
      textStyle: caption1,
      color: Colors.white,
    ),
  );
}
```

### Implementing the ChartTheme Interface

For complete control, you can implement the `ChartTheme` interface:

```dart
class CompletelyCustomTheme implements ChartTheme {
  @override
  Color get backgroundColor => Colors.black;
  
  @override
  GridStyle get gridStyle => GridStyle(
    gridLineColor: Colors.grey[800]!,
    xLabelStyle: TextStyle(
      color: Colors.grey[400],
      fontSize: 12,
    ),
    yLabelStyle: TextStyle(
      color: Colors.grey[400],
      fontSize: 12,
    ),
  );
  
  @override
  CrosshairStyle get crosshairStyle => CrosshairStyle(
    lineColor: Colors.white,
    labelBackgroundColor: Colors.white.withOpacity(0.8),
    labelTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 12,
    ),
  );
  
  @override
  LineStyle get defaultLineStyle => LineStyle(
    color: Colors.blue,
    thickness: 2,
  );
  
  @override
  CandleStyle get defaultCandleStyle => CandleStyle(
    positiveColor: Colors.green,
    negativeColor: Colors.red,
    wickWidth: 1,
    bodyWidth: 8,
  );
  
  @override
  OHLCStyle get defaultOHLCStyle => OHLCStyle(
    positiveColor: Colors.green,
    negativeColor: Colors.red,
    thickness: 1,
    width: 8,
  );
  
  @override
  HollowCandleStyle get defaultHollowCandleStyle => HollowCandleStyle(
    positiveColor: Colors.green,
    negativeColor: Colors.red,
    wickWidth: 1,
    bodyWidth: 8,
    hollowPositiveColor: Colors.transparent,
  );
  
  @override
  HorizontalBarrierStyle get defaultHorizontalBarrierStyle => HorizontalBarrierStyle(
    color: Colors.purple,
    isDashed: true,
    lineThickness: 1,
    labelBackgroundColor: Colors.purple.withOpacity(0.8),
    labelTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  );
  
  @override
  VerticalBarrierStyle get defaultVerticalBarrierStyle => VerticalBarrierStyle(
    color: Colors.orange,
    isDashed: true,
    lineThickness: 1,
    labelBackgroundColor: Colors.orange.withOpacity(0.8),
    labelTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
  );
  
  // Implement all other required properties...
  
  @override
  TextStyle textStyle({
    required TextStyle textStyle,
    required Color color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return textStyle.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
```

## Theme Properties

The `ChartTheme` interface defines numerous properties that control the appearance of different chart elements:

### Core Properties

- `backgroundColor`: The background color of the chart
- `gridStyle`: The style of the grid lines and labels
- `crosshairStyle`: The style of the crosshair

### Series Styles

- `defaultLineStyle`: The default style for line series
- `defaultCandleStyle`: The default style for candle series
- `defaultOHLCStyle`: The default style for OHLC series
- `defaultHollowCandleStyle`: The default style for hollow candle series

### Annotation Styles

- `defaultHorizontalBarrierStyle`: The default style for horizontal barriers
- `defaultVerticalBarrierStyle`: The default style for vertical barriers
- `defaultTickIndicatorStyle`: The default style for tick indicators

### Marker Styles

- `defaultMarkerStyle`: The default style for markers
- `defaultActiveMarkerStyle`: The default style for active markers
- `defaultEntryTickStyle`: The default style for entry tick markers
- `defaultExitTickStyle`: The default style for exit tick markers

## Style Classes

The Deriv Chart library provides several style classes that define the appearance of specific chart elements:

### GridStyle

Controls the appearance of grid lines and labels:

```dart
GridStyle(
  gridLineColor: Colors.grey[300]!,
  xLabelStyle: TextStyle(
    color: Colors.grey[600],
    fontSize: 12,
  ),
  yLabelStyle: TextStyle(
    color: Colors.grey[600],
    fontSize: 12,
  ),
)
```

### CrosshairStyle

Controls the appearance of the crosshair:

```dart
CrosshairStyle(
  lineColor: Colors.blue,
  lineThickness: 1,
  lineDashPattern: [5, 5], // Dashed line
  labelBackgroundColor: Colors.blue.withOpacity(0.8),
  labelTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 12,
  ),
  labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  labelBorderRadius: 4,
)
```

### LineStyle

Controls the appearance of line series:

```dart
LineStyle(
  color: Colors.blue,
  thickness: 2,
  isDashed: false,
  dashPattern: [5, 5],
)
```

### CandleStyle

Controls the appearance of candle series:

```dart
CandleStyle(
  positiveColor: Colors.green,
  negativeColor: Colors.red,
  wickWidth: 1,
  bodyWidth: 8,
)
```

### OHLCStyle

Controls the appearance of OHLC series:

```dart
OHLCStyle(
  positiveColor: Colors.green,
  negativeColor: Colors.red,
  thickness: 1,
  width: 8,
)
```

### HorizontalBarrierStyle

Controls the appearance of horizontal barriers:

```dart
HorizontalBarrierStyle(
  color: Colors.purple,
  isDashed: true,
  lineThickness: 1,
  labelBackgroundColor: Colors.purple.withOpacity(0.8),
  labelTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 12,
  ),
)
```

## Using Custom Themes

To use a custom theme, pass it to the `theme` parameter of the `Chart` widget:

```dart
Chart(
  mainSeries: LineSeries(ticks),
  pipSize: 2,
  theme: CustomDarkTheme(),
)
```

## Dynamic Theme Switching

You can dynamically switch between themes based on user preferences or system settings:

```dart
class ThemeSwitcherExample extends StatefulWidget {
  final List<Tick> ticks;
  
  const ThemeSwitcherExample({
    Key? key,
    required this.ticks,
  }) : super(key: key);
  
  @override
  State<ThemeSwitcherExample> createState() => _ThemeSwitcherExampleState();
}

class _ThemeSwitcherExampleState extends State<ThemeSwitcherExample> {
  bool _isDarkMode = true;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Light'),
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
            Text('Dark'),
          ],
        ),
        Expanded(
          child: Chart(
            mainSeries: LineSeries(widget.ticks),
            pipSize: 2,
            theme: _isDarkMode ? ChartDefaultDarkTheme() : ChartDefaultLightTheme(),
          ),
        ),
      ],
    );
  }
}
```

## Next Steps

Now that you understand how to create and use custom themes in the Deriv Chart library, you can explore:

- [Real-time Data](real_time_data.md) - Understand how to handle real-time data updates
- [API Reference](../api_reference/chart_widget.md) - Explore the complete API
