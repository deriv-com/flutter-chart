# Chart Interactions

Flutter Chart provides rich interactive features to enhance user experience.

## Zoom
Users can zoom in/out of the chart using:
- Pinch gestures
- Double tap
- Zoom buttons (if enabled)

## Scroll
Horizontal scrolling allows users to view different time periods:
- Swipe gestures
- Edge scrolling
- Momentum scrolling

## Crosshair
The crosshair feature helps users precisely read values:
- Shows exact price at cursor position
- Displays time at cursor position
- Updates in real-time as user moves across chart
- Can be enabled/disabled using `showCrosshair` parameter

## Data Fit
Automatically fits the chart data to the visible area:
- Enable/disable using `dataFitEnabled`
- Customize padding with `dataFitPadding`
- Toggle data fit button visibility with `showDataFitButton`

## Live Updates
Support for real-time data updates:
- Enable live mode with `isLive`
- Customize current tick animation with `currentTickAnimationDuration`
- Enable/disable tick blink animation with `showCurrentTickBlinkAnimation`

## Example Configuration
```dart
DerivChart(
  mainSeries: LineSeries([/* your list of ticks */]),
  granularity: 1000,
  activeSymbol: 'R_100',
  showCrosshair: true,
  dataFitEnabled: true,
  isLive: true,
  onCrosshairAppeared: (crosshairState) {
    // Handle crosshair appearance
  },
  onCrosshairDisappeared: () {
    // Handle crosshair disappearance
  },
  onCrosshairHover: (crosshairState) {
    // Handle crosshair hover
  },
)
