# Chart Markers Revamp – Consumer Migration Guide

This document summarizes ONLY the breaking changes and consumer-facing communication changes introduced in the `chart-markers-revamp`, with concrete actions you need to take to keep your app compiling and to render the new/updated markers correctly.

## Scope
- Marker APIs (models, series, and tapping/gestures)
- Marker rendering and snapping behavior
- Theme and icon assets consumed by marker styles
- X-axis and chart configuration affecting marker alignment

## Breaking API & Behavior Changes

### 1) Marker grouping and active marker group
- **What changed**:
  - `MarkerGroup` now has a new required parameter `direction` and new optional parameters: `currentEpoch`, `profitAndLossText`, and `onTap`.
  - New class `ActiveMarkerGroup extends MarkerGroup` adds `onTapOutside` handler while inheriting the base params.
  - `MarkerGroupSeries` accepts an optional `activeMarkerGroup` and respects marker groups visibility with special handling for `contractMarker`.
- **Why it matters**: Consumer code creating grouped markers or driving active states must pass these new parameters to enable animations, tap behaviors, and P/L label.
- **What to do**:
  1. Update your grouped marker construction:

```dart
final group = MarkerGroup(
  <ChartMarker>[ /* contractMarker, start/exit,... */ ],
  type: 'tick',
  direction: MarkerDirection.up, // or MarkerDirection.down
  id: 'your_group_id',
  currentEpoch: latestTickEpoch, // required for dynamic progress/animations
  profitAndLossText: '+0.00 USD',
  onTap: () { /* handle tap on circular contract marker */ },
);
```

```dart
final active = ActiveMarkerGroup(
  markers: group.markers,
  type: group.type,
  direction: group.direction,
  id: group.id,
  currentEpoch: latestTickEpoch,
  profitAndLossText: group.profitAndLossText,
  onTap: group.onTap,
  onTapOutside: () { /* clear active state in your app */ },
);
```

  2. If you expose grouped markers to the chart, provide an `activeMarkerGroup` to let the chart render the P/L label, contract circle, and tap areas correctly.

### 2) ChartMarker and Marker tap callbacks
- **What changed**: `ChartMarker` now forwards a `VoidCallback? onTap` to base `Marker`.
- **Why it matters**: Contract circle taps are routed to either `MarkerGroup.onTap` or `ActiveMarkerGroup.onTap`. Non-grouped markers still use their own `onTap`.
- **What to do**: When constructing a `ChartMarker` of type `contractMarker`, provide `onTap` if you want to react to taps on the circle.

```dart
ChartMarker(
  epoch: startEpoch,
  quote: startQuote,
  direction: MarkerDirection.up,
  markerType: MarkerType.contractMarker,
  onTap: () { /* open contract details */ },
);
```

### 3) MarkerProps additions
- **What changed**: `MarkerProps` adds `isProfit`, `isRunning`, `markerLabel`, and `contractMarkerLeftPadding`.
- **Why it matters**:
  - Painters use these to style lines, circle fill/border, and optional label inside contract circle.
  - `contractMarkerLeftPadding` controls the horizontal padding from the left chart edge to the LEFT EDGE of the circular `contractMarker`. This is respected by both the base marker painter and the active marker group painter. Default is 8 pixels.
- **What to do**: Populate `MarkerGroup.props` appropriately.

```dart
MarkerGroup(
  markers,
  type: 'tick',
  direction: MarkerDirection.up, // or MarkerDirection.down
  props: MarkerProps(
    isProfit: true,                 // or false
    isRunning: false,               // false when contract is closed
    markerLabel: 'NT',              // optional; otherwise arrow is shown
    contractMarkerLeftPadding: 16,  // horizontal padding from left edge
  ),
);
```

### 4) New/updated MarkerType values
- **What changed**: The enum adds/renames key values for the revamp, including: `contractMarker`, `startTime`, `exitTime`, `startTimeCollapsed`, `exitTimeCollapsed`, `profitAndLossLabel` and `profitAndLossLabelFixed`.
- **Why it matters**: Painters rely on specific types to render the correct visuals (vertical line + icon, Profit/Loss, etc.). The collapsed time markers draw short solid vertical connectors for condensed view and are connected by a solid line when both are present.
- **What to do**: Use the standard `startTime` and `exitTime` markers for full vertical lines with bottom icons. In compact contexts (e.g., chart page), use `startTimeCollapsed` and `exitTimeCollapsed` to render minimal time markers.

Usage of collapsed time markers:

```dart
// Add compact start/end connectors around your entry/exit when space is tight
chartMarkers.addAll(<ChartMarker>[
  ChartMarker(
    epoch: startTimeEpoch, // slight lead for visual clarity
    quote: startQuote,
    direction: direction,
    markerType: MarkerType.startTimeCollapsed,
  ),
  ChartMarker(
    epoch: entryTickEpoch,
    quote: startQuote,
    direction: direction,
    markerType: MarkerType.entryTick,
  ),
  ChartMarker(
    epoch: exitTimeEpoch,
    quote: startQuote,
    direction: direction,
    markerType: MarkerType.exitTimeCollapsed,
  ),
]);
```

### 5) Snapping markers to granularity intervals
- **What changed**:
  - `ChartConfig` adds `snapMarkersToIntervals` (default: true).
  - `XAxisModel` constructor now requires `snapMarkersToIntervals` and exposes `xFromEpochSnapped` that snaps epochs to the center of the granularity bucket.
  - Marker painting uses `xFromEpochSnapped` to align markers to candle centerlines.
- **Why it matters**: If you construct `XAxisModel` or build `Chart` with a custom config, you must pass this flag intentionally. Markers will be center-aligned to candles when true.
- **What to do**:

```dart
final chartConfig = ChartConfig(
  granularity: granularityMs,
  snapMarkersToIntervals: true, // default is true; set explicitly if you manage config
);
```

If you instantiate `XAxisModel` directly in custom setups, provide `snapMarkersToIntervals`:

```dart
final xAxis = XAxisModel(
  entries: ticks,
  granularity: granularityMs,
  animationController: controller,
  isLive: true,
  snapMarkersToIntervals: true,
  maxCurrentTickOffset: 150,
);
```

### 6) MarkerArea animation info and active group overlay
- **What changed**: `MarkerArea` requires a new `animationInfo` parameter. The overlay adds `AnimatedActiveMarkerGroup` that paints the active group label and circle with animations. Base series painter opacity dims when an active marker/group is present.
- **Why it matters**: If you embed `MarkerArea` directly, you must pass `AnimationInfo` to keep animations smooth and consistent with the chart.
- **What to do**:

```dart
MarkerArea(
  markerSeries: series,
  quoteToCanvasY: quoteToCanvasY,
  animationInfo: const AnimationInfo(
    currentTickPercent: 0.0, // or bind to your animation driver
  ),
);
```

### 7) Gesture communication updates
- **What changed**:
  - The gesture layer tracks global start/last points and last pointer kind, and tap routing for active markers/groups distinguishes between tapping inside the contract circle and outside.
- **Why it matters**: Your `onTap` and `onTapOutside` handlers for `ActiveMarker`/`ActiveMarkerGroup` should clear or update active state accordingly.
- **What to do**: Ensure your handlers are wired:

```dart
_activeMarkerGroup = ActiveMarkerGroup(
  markers: markers,
  type: 'tick',
  direction: MarkerDirection.up, // or MarkerDirection.down
  id: id,
  currentEpoch: nowEpoch,
  onTap: () => openContract(id),
  onTapOutside: () => setState(() => _activeMarkerGroup = null),
);
```

### 8) Time marker utilities and icons
- **What changed**:
  - Start/end time vertical lines and bottom icons are painted via utilities; `MarkerStyle` now references `QuillIcons.stopwatch` and `QuillIcons.flag_checkered`.
  - A new font `assets/fonts/quill_icons.ttf` is bundled and declared in `pubspec.yaml` under the `QuillIcons` family.
- **Why it matters**: If you customized marker icons or rely on font assets, ensure your app bundles these assets (the library already declares them, but your build must not remove them).
- **What to do**:
  - Ensure your CI/build does not tree-shake the icon font if you build examples yourself. The repo already adds `--no-tree-shake-icons` for APK builds.
  - If you copy styles, keep using `MarkerStyle.startTimeIcon` and `MarkerStyle.endTimeIcon`.

### 9) Theme additions for P/L and closed markers
- **What changed**: New text styles and colors for closed markers and profit/loss labels were added to the theme (light/dark) including `profitAndLossLabelTextStyle` and palette colors.
- **Why it matters**: If you provide a custom `ChartTheme` or `MarkerStyle`, align your styles to include these fields.
- **What to do**: Update your custom theme overrides to include the new text styles and palette fields used by marker painters.

## Minimal Example: Rise/Fall grouped markers

```dart
// Convert your basic markers to grouped markers with contract circle and P/L label
List<MarkerGroup> buildGroups(List<Marker> markers, int nowEpoch) {
  return markers.map((m) {
    final endEpoch = m.epoch + 3000; // your duration

    final parts = <ChartMarker>[
      ChartMarker(epoch: m.epoch, quote: m.quote, direction: m.direction, markerType: MarkerType.entryTick),
      ChartMarker(epoch: endEpoch, quote: m.quote, direction: m.direction, markerType: MarkerType.exitTime),
      ChartMarker(
        epoch: m.epoch,
        quote: m.quote,
        direction: m.direction,
        markerType: MarkerType.contractMarker,
        onTap: () { /* toggle active */ },
      ),
    ];

    // Optionally show P/L label
    parts.add(
      ChartMarker(
        epoch: endEpoch,
        quote: m.quote,
        direction: m.direction,
        markerType: MarkerType.profitAndLossLabel,
      ),
    );

    return MarkerGroup(
      parts,
      type: 'tick',
      direction: m.direction,
      id: 'group_${m.epoch}',
      currentEpoch: nowEpoch,
      profitAndLossText: '+9.55 USD',
      props: const MarkerProps(
        isProfit: true,
        isRunning: false,
        contractMarkerLeftPadding: 16,
      ),
      onTap: () { /* open details */ },
    );
  }).toList();
}
```

## Checklist for Consumers
- [ ] Replace direct marker usage with `MarkerGroup`/`MarkerGroupSeries` when you need contract visuals (circle, lines, P/L label)
- [ ] Provide `currentEpoch` and, if applicable, `profitAndLossText`, `onTap` in `MarkerGroup`
- [ ] Use `ActiveMarkerGroup` and wire `onTapOutside` to clear active state
- [ ] Update `MarkerProps` with `isProfit`, `isRunning`, and optional `markerLabel`
- [ ] Use new `MarkerType` values: `contractMarker`, `startTime`, `exitTime`, `profitAndLossLabel`, and use `startTimeCollapsed`/`exitTimeCollapsed` for condensed layouts when needed
- [ ] Ensure `ChartConfig.snapMarkersToIntervals` is set appropriately (default true)
- [ ] If you instantiate `XAxisModel`, pass `snapMarkersToIntervals`
- [ ] Pass `animationInfo` to `MarkerArea` if you embed it directly
- [ ] Ensure icon font `QuillIcons` is available (no tree-shake of icons in your builds that integrate the example)
- [ ] Align custom themes with new marker colors and `profitAndLossLabelTextStyle`
