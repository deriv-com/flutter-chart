# Chart Customization

Customize the appearance and behavior of your charts.

## Theme Customization
- Chart colors
- Line styles
- Candlestick styles
- Grid appearance
- Axis labels

## Marker Styles
- Entry/Exit markers
- Time markers
- Price markers
- Custom markers

## Layout Options
- Chart padding
- Axis visibility
- Label formatting
- Grid lines

## Example
```dart
DerivChart(
  theme: ChartTheme(
    candleStyle: CandleStyle(
      bullColor: Colors.green,
      bearColor: Colors.red,
    ),
    gridStyle: GridStyle(
      color: Colors.grey.withOpacity(0.2),
      dashArray: [2, 2],
    ),
  ),
)
